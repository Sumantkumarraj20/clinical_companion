import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_configuration.dart';
import 'core/config/secure_config_service.dart';
import 'core/providers/app_providers.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storedKeys = await SecureConfigService().loadKeys();
  final configuration = storedKeys.isComplete
      ? AppConfiguration.fromStoredKeys(storedKeys)
      : AppConfiguration.fromEnvironment();
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
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
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
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        cardTheme: _cardTheme,
      ),
      routerConfig: router,
    );
  }
}
