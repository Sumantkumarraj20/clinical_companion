import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_configuration.dart';
import '../../../core/config/secure_config_service.dart';
import '../../../core/database/database_sideload_service.dart';
import '../../../core/utils/portable_directory.dart';
import '../../../core/providers/app_providers.dart';

class ConfigurationScreen extends ConsumerStatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  ConsumerState<ConfigurationScreen> createState() =>
      _ConfigurationScreenState();
}

class _ConfigurationScreenState extends ConsumerState<ConfigurationScreen> {
  late final TextEditingController _supabaseUrl;
  late final TextEditingController _supabaseKey;
  late final TextEditingController _geminiKey;
  late final TextEditingController _databasePassword;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final configuration = ref.read(appConfigurationProvider);
    _supabaseUrl = TextEditingController(text: configuration.supabaseUrl);
    _supabaseKey = TextEditingController(
      text: configuration.supabasePublishableKey,
    );
    _geminiKey = TextEditingController(text: configuration.geminiApiKey);
    _databasePassword = TextEditingController(
      text: configuration.databasePassword,
    );
  }

  @override
  void dispose() {
    _supabaseUrl.dispose();
    _supabaseKey.dispose();
    _geminiKey.dispose();
    _databasePassword.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_supabaseUrl.text.trim().isEmpty ||
        _supabaseKey.text.trim().isEmpty ||
        _geminiKey.text.trim().isEmpty ||
        _databasePassword.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter all three configuration keys.')),
      );
      return;
    }
    final supabaseUri = Uri.tryParse(_supabaseUrl.text.trim());
    if (supabaseUri == null ||
        (supabaseUri.scheme != 'https' && supabaseUri.scheme != 'http') ||
        supabaseUri.host.isEmpty ||
        (supabaseUri.path.isNotEmpty && supabaseUri.path != '/')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use a Supabase project URL such as https://your-project.supabase.co.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await SecureConfigService().saveKeys(
        _supabaseUrl.text,
        _supabaseKey.text,
        _geminiKey.text,
        _databasePassword.text,
      );
      final configuration = AppConfiguration(
        supabaseUrl: _supabaseUrl.text.trim(),
        supabasePublishableKey: _supabaseKey.text.trim(),
        ownerId: ref.read(appConfigurationProvider).ownerId,
        geminiApiKey: _geminiKey.text.trim(),
        databasePassword: _databasePassword.text.trim(),
      );
      ref.read(appConfigurationProvider.notifier).setConfiguration(configuration);
      try {
        await Supabase.initialize(
          url: configuration.supabaseUrl,
          publishableKey: configuration.supabasePublishableKey,
        );
      } catch (_) {
        // Supabase throws when it is already initialized; the stored config is valid.
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration saved securely.')),
        );
        context.go('/dashboard');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _importDatabase(String destinationName, String label) async {
    try {
      final picked = await FilePicker.platform.pickFiles(type: FileType.any);
      final selectedPath = picked?.files.single.path;
      if (selectedPath == null) return;
      final directory = await getPortableStorageDirectory();
      final selectedFile = File(selectedPath);
      final importedFile = await selectedFile.copy(
        path.join(directory.path, destinationName),
      );
      if (destinationName == 'pmjay_hbp.sqlite') {
        await ref.read(appDatabaseProvider).customSelect('SELECT 1').get();
        await DatabaseSideloadService().mergePmjayCatalog(
          pmjayDatabase: importedFile,
          database: ref.read(appDatabaseProvider),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label imported successfully.')),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not import database: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Secure configuration')),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Connect clinical services', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                const Text('Configuration is encrypted into config.aes inside the portable clinical_data folder.'),
                const SizedBox(height: 24),
                TextField(controller: _supabaseUrl, decoration: const InputDecoration(labelText: 'Supabase URL')),
                const SizedBox(height: 12),
                TextField(controller: _supabaseKey, obscureText: true, decoration: const InputDecoration(labelText: 'Supabase publishable key')),
                const SizedBox(height: 12),
                TextField(controller: _geminiKey, obscureText: true, decoration: const InputDecoration(labelText: 'Gemini API key')),
                const SizedBox(height: 12),
                TextField(controller: _databasePassword, obscureText: true, decoration: const InputDecoration(labelText: 'Database password')),
                const SizedBox(height: 20),
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.lock_outline),
                    label: Text(_saving ? 'Saving...' : 'Save & Initialize'),
                  ),
                ),
                const SizedBox(height: 36),
                Text('Sideload databases', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text('Use this when a platform build cannot extract the bundled SQLite catalog.'),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _importDatabase('clinical_drugs.sqlite', 'Pharmacopeia database'),
                  icon: const Icon(Icons.medication_outlined),
                  label: const Text('Import Pharmacopeia Database'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _importDatabase('pmjay_hbp.sqlite', 'PM-JAY database'),
                  icon: const Icon(Icons.account_balance_outlined),
                  label: const Text('Import PM-JAY Database'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}