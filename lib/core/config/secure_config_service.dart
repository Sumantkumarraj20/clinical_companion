import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path/path.dart' as path;

import '../utils/portable_directory.dart';

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

class SecureConfigService {
  // This obscures the portable file; it is not a substitute for a user PIN or
  // an operator-managed secret because the application must decrypt it itself.
  static final _key = encrypt.Key.fromUtf8('12345678901234567890123456789012');
  static final _iv = encrypt.IV.fromUtf8('1234567890123456');
  static final _cipher = encrypt.Encrypter(encrypt.AES(_key));

  Future<File> _file() async {
    final directory = await getPortableStorageDirectory();
    return File(path.join(directory.path, 'config.aes'));
  }

  Future<void> saveKeys(
    String supabaseUrl,
    String supabaseAnon,
    String geminiKey,
    String databasePassword,
  ) async {
    final payload = jsonEncode({
      'supabase_url': supabaseUrl.trim(),
      'supabase_publishable_key': supabaseAnon.trim(),
      'gemini_api_key': geminiKey.trim(),
      'database_password': databasePassword.trim(),
    });
    final file = await _file();
    await file.writeAsString(_cipher.encrypt(payload, iv: _iv).base64);
  }

  Future<StoredKeys> loadKeys() async {
    try {
      final file = await _file();
      if (!await file.exists()) return _empty();
      final payload = jsonDecode(
        _cipher.decrypt64(await file.readAsString(), iv: _iv),
      );
      if (payload is! Map) return _empty();
      return StoredKeys(
        supabaseUrl: payload['supabase_url']?.toString() ?? '',
        supabasePublishableKey:
            payload['supabase_publishable_key']?.toString() ?? '',
        geminiKey: payload['gemini_api_key']?.toString() ?? '',
        databasePassword: payload['database_password']?.toString() ?? '',
      );
    } on Object catch (_) {
      return _empty();
    }
  }

  StoredKeys _empty() => const StoredKeys(
    supabaseUrl: '',
    supabasePublishableKey: '',
    geminiKey: '',
    databasePassword: '',
  );
}