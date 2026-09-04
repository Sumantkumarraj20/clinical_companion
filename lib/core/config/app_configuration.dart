/// Runtime configuration supplied with `--dart-define` when building the app.
///
/// The application remains usable offline without Supabase. In that mode every
/// local record is assigned to [ownerId], which can be replaced by a real
/// authenticated user as soon as cloud sync is configured.
class AppConfiguration {
  const AppConfiguration({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.ownerId,
    this.geminiApiKey = '',
  });

  factory AppConfiguration.fromEnvironment() => const AppConfiguration(
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
    ownerId: String.fromEnvironment(
      'CLINICAL_OWNER_ID',
      defaultValue: 'local-practitioner',
    ),
    geminiApiKey: String.fromEnvironment('GEMINI_API_KEY'),
  );

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String ownerId;
  final String geminiApiKey;

  bool get hasSupabase =>
      Uri.tryParse(supabaseUrl)?.hasScheme == true &&
      supabaseAnonKey.trim().isNotEmpty;

  bool get hasGemini => geminiApiKey.trim().isNotEmpty;
}
