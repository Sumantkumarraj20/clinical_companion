import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoredKeys {
  const StoredKeys({
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    required this.geminiKey,
    required this.databasePassword,
  });

  final String supabaseUrl;
  final String supabasePublishableKey;
  final String geminiKey;
  final String databasePassword;

  bool get isComplete =>
      supabaseUrl.trim().isNotEmpty &&
      supabasePublishableKey.trim().isNotEmpty &&
      geminiKey.trim().isNotEmpty &&
      databasePassword.trim().isNotEmpty;
}

/// The single source of runtime credentials. Android uses Keystore-backed
/// encrypted storage and iOS uses Keychain; no credential is written to a
/// portable file or application preference.
class SecureConfigService {
  SecureConfigService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const supabaseUrlKey = 'SUPABASE_URL';
  static const supabaseAnonKey = 'SUPABASE_ANON_KEY';
  static const supabasePasswordKey = 'SUPABASE_PASSWORD';
  static const geminiApiKey = 'GEMINI_API_KEY';

  // Never commit credentials to a client repository. Development/CI supplies
  // these once at build time with --dart-define; after first launch they live
  // in platform secure storage and remain editable in Settings.
  static const _defaults = <String, String>{
    supabaseUrlKey: String.fromEnvironment(supabaseUrlKey),
    supabaseAnonKey: String.fromEnvironment(supabaseAnonKey),
    supabasePasswordKey: String.fromEnvironment(supabasePasswordKey),
    geminiApiKey: String.fromEnvironment(geminiApiKey),
  };

  final FlutterSecureStorage _storage;

  /// Seeds only a completely empty store, preserving clinicians' edits.
  /// Empty build defines intentionally produce an unconfigured app rather
  /// than persisting placeholders or secrets in the repository.
  Future<StoredKeys> initialize() async {
    final existing = await _storage.readAll();
    if (_defaults.values.any((value) => value.trim().isNotEmpty) &&
        _defaults.keys.every((key) => (existing[key] ?? '').trim().isEmpty)) {
      for (final entry in _defaults.entries) {
        await _storage.write(key: entry.key, value: entry.value);
      }
    }
    return loadKeys();
  }

  Future<String> read(String key) async =>
      (await _storage.read(key: key)) ?? '';

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value.trim());

  Future<void> saveKeys(
    String supabaseUrl,
    String supabaseAnon,
    String geminiKey,
    String databasePassword,
  ) async {
    await Future.wait([
      write(supabaseUrlKey, supabaseUrl),
      write(supabaseAnonKey, supabaseAnon),
      write(geminiApiKey, geminiKey),
      write(supabasePasswordKey, databasePassword),
    ]);
  }

  Future<StoredKeys> loadKeys() async {
    final values = await _storage.readAll();
    return StoredKeys(
      supabaseUrl: values[supabaseUrlKey] ?? '',
      supabasePublishableKey: values[supabaseAnonKey] ?? '',
      geminiKey: values[geminiApiKey] ?? '',
      databasePassword: values[supabasePasswordKey] ?? '',
    );
  }
}
