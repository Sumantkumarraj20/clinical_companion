import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.clinical_companion"
    compileSdk = flutter.compileSdkVersion
    // Sprint 27 (CI): pin the NDK to the version pre-installed on GitHub
    // Actions Ubuntu runners. Leaving this as flutter.ndkVersion makes Gradle
    // download NDK 28.2 (~1.5 GB) and re-solve the toolchain on every build;
    // an exact match lets the build use the runner's local NDK instead.
    ndkVersion = "26.1.10909125"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // NOTE: `com.example.clinical_companion` is intentionally left as-is.
        // Clinicians already have this app installed under this id; changing it
        // would make every upgrade impossible, because Android treats a new
        // applicationId as a different app and refuses to replace the old one
        // ("package conflicts with an existing package").
        applicationId = "com.example.clinical_companion"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Sprint 17.6 — ONE stable signing key for every release build.
        //
        // Release builds used to be signed with the machine-local Android DEBUG
        // key. Debug keys are generated per machine, so an APK built on a
        // laptop and one built in CI are signed with DIFFERENT keys, and
        // Android refuses to install one over the other ("package conflicts
        // with an existing package").
        //
        // Credentials come from android/key.properties (git-ignored) or from
        // the SIGNING_* env vars CI injects.
        create("release") {
            val props = Properties()
            val propsFile = rootProject.file("key.properties")
            if (propsFile.exists()) {
                propsFile.inputStream().use { props.load(it) }
            }

            fun setting(name: String, env: String): String? =
                props.getProperty(name) ?: System.getenv(env)

            // NOTE: locals are suffixed `Setting` on purpose — an unsuffixed
            // `val storePassword = ...` would shadow the signing config's
            // `var storePassword` below and make `storePassword = storePassword`
            // a "val cannot be reassigned" compile error in the Kotlin DSL.
            val storeFileSetting = setting("storeFile", "SIGNING_KEY_PATH")
            val storePasswordSetting = setting("storePassword", "SIGNING_KEY_PASSWORD")
            val keyAliasSetting = setting("keyAlias", "SIGNING_KEY_ALIAS")
            val keyPasswordSetting = setting("keyPassword", "SIGNING_KEY_PASSWORD")

            if (storeFileSetting != null &&
                storePasswordSetting != null &&
                keyAliasSetting != null &&
                keyPasswordSetting != null
            ) {
                storeFile = file(storeFileSetting)
                storePassword = storePasswordSetting
                keyAlias = keyAliasSetting
                keyPassword = keyPasswordSetting
            } else {
                // FAIL LOUDLY. Silently falling back to the debug key is what
                // produced un-upgradeable APKs: the build "succeeded" and the
                // clinician's next install broke.
                logger.error(
                    "ClinCom release signing is not configured. Create " +
                        "android/key.properties (see android/key.properties.example) " +
                        "or set SIGNING_KEY_PATH / SIGNING_KEY_ALIAS / " +
                        "SIGNING_KEY_PASSWORD."
                )
            }
        }
    }

    buildTypes {
        release {
            // Signed with the shared release key so every build can upgrade the
            // previously installed one.
            signingConfig = signingConfigs.getByName("release")
            // ML Kit + R8: keep shrinking enabled but apply our keep rules so
            // missing vision_text_common sub-modules don't fail assembleRelease.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// Sprint 27 (CI) — no custom APK rename: the release workflows verify and
// publish `build/app/outputs/flutter-apk/app-release.apk` exactly, so the
// Flutter/Gradle default filename must be preserved. (A ClinCom-<version>
// rename here would re-break the `ls .../app-release.apk` verification step
// with "No such file or directory".)
