import 'secure_config_service.dart';

/// Runtime configuration supplied by secure storage or build-time defaults.
///
/// The application remains usable offline without Supabase. In that mode every
/// local record is assigned to [ownerId], which can be replaced by a real
/// authenticated user as soon as cloud sync is configured.
class AppConfiguration {
  const AppConfiguration({
    required this.supabaseUrl,
    String? supabasePublishableKey,
    @Deprecated('Use supabasePublishableKey') String? supabaseAnonKey,
    required this.ownerId,
    this.geminiApiKey = '',
    this.databasePassword = '',
  }) : supabasePublishableKey =
           supabasePublishableKey ?? supabaseAnonKey ?? '';

  factory AppConfiguration.fromEnvironment() => const AppConfiguration(
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabasePublishableKey: String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
    ownerId: String.fromEnvironment(
      'CLINICAL_OWNER_ID',
      defaultValue: 'local-practitioner',
    ),
    geminiApiKey: String.fromEnvironment('GEMINI_API_KEY'),
    databasePassword: String.fromEnvironment('DATABASE_PASSWORD'),
  );

  factory AppConfiguration.fromStoredKeys(StoredKeys keys) => AppConfiguration(
    supabaseUrl: keys.supabaseUrl,
    supabasePublishableKey: keys.supabasePublishableKey,
    ownerId: 'local-practitioner',
    geminiApiKey: keys.geminiKey,
    databasePassword: keys.databasePassword,
  );

  final String supabaseUrl;
  final String supabasePublishableKey;
  final String ownerId;
  final String geminiApiKey;
  final String databasePassword;

  @Deprecated('Use supabasePublishableKey')
  String get supabaseAnonKey => supabasePublishableKey;

  bool get hasSupabase =>
      Uri.tryParse(supabaseUrl)?.hasScheme == true &&
      supabasePublishableKey.trim().isNotEmpty;

  bool get hasGemini => geminiApiKey.trim().isNotEmpty;

  bool get hasDatabasePassword => databasePassword.trim().isNotEmpty;
}
