package com.example.clinical_companion

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageInstaller
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

private const val INSTALLER_CHANNEL = "clincom/ota_installer"
private const val INSTALLER_EVENTS_CHANNEL = "clincom/ota_installer/events"
private const val INSTALL_STATUS_ACTION =
    "com.example.clinical_companion.OTA_INSTALL_STATUS"
private const val INSTALL_STATUS_EVENT_ACTION =
    "com.example.clinical_companion.OTA_INSTALL_STATUS_EVENT"

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            INSTALLER_CHANNEL,
        ).setMethodCallHandler { call, result ->
            if (call.method != "installApkSilently") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val filePath = call.argument<String>("filePath")
            if (filePath.isNullOrBlank()) {
                result.error("invalid_path", "APK file path is required.", null)
                return@setMethodCallHandler
            }

            Thread {
                try {
                    installApk(filePath)
                    runOnUiThread { result.success(true) }
                } catch (error: Exception) {
                    runOnUiThread {
                        result.error(
                            "install_failed",
                            error.message ?: "Android could not start the APK installation.",
                            null,
                        )
                    }
                }
            }.start()
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            INSTALLER_EVENTS_CHANNEL,
        ).setStreamHandler(object : EventChannel.StreamHandler {
            private var statusReceiver: BroadcastReceiver? = null

            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                statusReceiver = object : BroadcastReceiver() {
                    override fun onReceive(context: Context, intent: Intent) {
                        events.success(
                            mapOf(
                                "status" to intent.getIntExtra(
                                    PackageInstaller.EXTRA_STATUS,
                                    PackageInstaller.STATUS_FAILURE,
                                ),
                                "message" to intent.getStringExtra(
                                    PackageInstaller.EXTRA_STATUS_MESSAGE,
                                ),
                                "success" to (
                                    intent.getIntExtra(
                                        PackageInstaller.EXTRA_STATUS,
                                        PackageInstaller.STATUS_FAILURE,
                                    ) == PackageInstaller.STATUS_SUCCESS
                                ),
                                "pendingUserAction" to intent.getBooleanExtra(
                                    "pendingUserAction",
                                    false,
                                ),
                            ),
                        )
                    }
                }
                val filter = IntentFilter(INSTALL_STATUS_EVENT_ACTION)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    registerReceiver(
                        statusReceiver,
                        filter,
                        Context.RECEIVER_NOT_EXPORTED,
                    )
                } else {
                    @Suppress("DEPRECATION")
                    registerReceiver(statusReceiver, filter)
                }
            }

            override fun onCancel(arguments: Any?) {
                statusReceiver?.let(::unregisterReceiver)
                statusReceiver = null
            }
        })
    }

    private fun installApk(filePath: String) {
        val apkFile = File(filePath)
        require(apkFile.isFile && apkFile.length() > 0) {
            "Downloaded APK is missing or empty."
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            openSystemInstaller(apkFile)
            return
        }

        val installer = packageManager.packageInstaller
        val params = PackageInstaller.SessionParams(
            PackageInstaller.SessionParams.MODE_FULL_INSTALL,
        ).apply {
            setAppPackageName(packageName)
            setRequireUserAction(
                PackageInstaller.SessionParams.USER_ACTION_NOT_REQUIRED,
            )
        }

        val sessionId = installer.createSession(params)
        var session: PackageInstaller.Session? = null
        try {
            val activeSession = installer.openSession(sessionId)
            session = activeSession
            FileInputStream(apkFile).use { input ->
                activeSession.openWrite("base.apk", 0, apkFile.length()).use { output ->
                    input.copyTo(output)
                    activeSession.fsync(output)
                }
            }

            val callback = Intent(this, OtaInstallStatusReceiver::class.java)
                .setAction(INSTALL_STATUS_ACTION)
            val flags = PendingIntent.FLAG_UPDATE_CURRENT or
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    PendingIntent.FLAG_MUTABLE
                } else {
                    0
                }
            val statusIntent = PendingIntent.getBroadcast(
                this,
                sessionId,
                callback,
                flags,
            )
            activeSession.commit(statusIntent.intentSender)
            activeSession.close()
            session = null
        } catch (error: Exception) {
            try {
                session?.abandon()
            } catch (_: Exception) {
                // Preserve the original installation error.
            }
            session?.close()
            throw error
        }
    }

    private fun openSystemInstaller(apkFile: File) {
        val uri: Uri = FileProvider.getUriForFile(
            this,
            "$packageName.fileprovider",
            apkFile,
        )
        val intent = Intent(Intent.ACTION_VIEW)
            .setDataAndType(uri, "application/vnd.android.package-archive")
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }
}

class OtaInstallStatusReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val status = intent.getIntExtra(
            PackageInstaller.EXTRA_STATUS,
            PackageInstaller.STATUS_FAILURE,
        )
        if (status == PackageInstaller.STATUS_PENDING_USER_ACTION) {
            val confirmationIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                intent.getParcelableExtra(
                    Intent.EXTRA_INTENT,
                    Intent::class.java,
                )
            } else {
                @Suppress("DEPRECATION")
                intent.getParcelableExtra(Intent.EXTRA_INTENT)
            }
            confirmationIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            if (confirmationIntent != null) {
                context.startActivity(confirmationIntent)
            }
        }

        context.sendBroadcast(
            Intent(INSTALL_STATUS_EVENT_ACTION)
                .setPackage(context.packageName)
                .putExtra(PackageInstaller.EXTRA_STATUS, status)
                .putExtra(
                    PackageInstaller.EXTRA_STATUS_MESSAGE,
                    intent.getStringExtra(PackageInstaller.EXTRA_STATUS_MESSAGE),
                )
                .putExtra(
                    "pendingUserAction",
                    status == PackageInstaller.STATUS_PENDING_USER_ACTION,
                ),
        )
    }
}
