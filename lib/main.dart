import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';

import 'core/config/app_configuration.dart';
import 'core/config/secure_config_service.dart';
import 'core/providers/app_providers.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    debugPrint('Unhandled clinical app error: $error\n$stackTrace');
    return true;
  };
  final storedKeys = await SecureConfigService().initialize();
  final configuration = AppConfiguration.fromStoredKeys(storedKeys);
  if (configuration.hasSupabase) {
    try {
      await Supabase.initialize(
        url: configuration.supabaseUrl,
        publishableKey: configuration.supabasePublishableKey,
      );
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
    }
  }
  GoogleFonts.config.allowRuntimeFetching = false;
  ErrorWidget.builder = (details) => _ClinicalErrorFallback(details: details);

  runApp(
    ProviderScope(
      overrides: [
        appConfigurationProvider.overrideWith(
          () => AppConfigurationNotifier(configuration),
        ),
      ],
      child: const ClinicalCompanionApp(),
    ),
  );
}

class _ClinicalErrorFallback extends StatelessWidget {
  const _ClinicalErrorFallback({required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) => Material(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.health_and_safety_outlined, size: 56),
            const SizedBox(height: 16),
            const Text('This clinical view needs to reload.'),
            const SizedBox(height: 8),
            const Text(
              'Your locally saved work is safe. Return to the dashboard and try again.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

class ClinicalCompanionApp extends ConsumerWidget {
  const ClinicalCompanionApp({super.key});

  // 3. Move the configuration objects OUT of the build method to prevent memory churn on 6GB RAM
  static final _colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xff0d6b61),
    brightness: Brightness.light,
  );

  static final _cardTheme = CardThemeData(
    clipBehavior: Clip.antiAlias,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Clinical Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: _colorScheme,
        textTheme: GoogleFonts.interTextTheme(),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF006A60),
          unselectedItemColor: const Color(0xFF707974),
          backgroundColor: _colorScheme.surface,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        cardTheme: _cardTheme,
      ),
      routerConfig: router,
    );
  }
}
