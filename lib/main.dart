import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_configuration.dart';
import 'core/providers/app_providers.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final configuration = AppConfiguration.fromEnvironment();
  if (configuration.hasSupabase) {
    await Supabase.initialize(
      url: configuration.supabaseUrl,
      anonKey: configuration.supabaseAnonKey,
    );
  }
  runApp(
    ProviderScope(
      overrides: [appConfigurationProvider.overrideWithValue(configuration)],
      child: const ClinicalCompanionApp(),
    ),
  );
}

class ClinicalCompanionApp extends ConsumerWidget {
  const ClinicalCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ColorScheme.fromSeed(
      seedColor: const Color(0xff0d6b61),
      brightness: Brightness.light,
    );
    return MaterialApp.router(
      title: 'Clinical Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colors,
        textTheme: GoogleFonts.interTextTheme(),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        cardTheme: CardThemeData(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
