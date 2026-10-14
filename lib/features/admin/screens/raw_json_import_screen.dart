import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ingestion/clinical_ingestion_mapper.dart';
import '../../../core/ingestion/json_schema_tool.dart';
import '../../../core/ingestion/live_ingestion_controller.dart';
import '../../../core/ui/raw_error.dart';

/// Developer backdoor: paste structured JSON and save it with the exact same
/// mapper used by the extraction pipeline.
class RawJsonImportScreen extends ConsumerStatefulWidget {
  const RawJsonImportScreen({super.key});

  @override
  ConsumerState<RawJsonImportScreen> createState() =>
      _RawJsonImportScreenState();
}

class _RawJsonImportScreenState extends ConsumerState<RawJsonImportScreen> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _copySchema() async {
    await Clipboard.setData(ClipboardData(text: buildIngestionSchemaTemplate()));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Schema copied to clipboard')));
  }

  Future<void> _import() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final decoded = jsonDecode(_controller.text);
      if (decoded is! Map) {
        throw const FormatException('Expected a JSON object at the top level.');
      }
      final result = await ClinicalIngestionMapper(
        ref.read(ingestionOrchestratorProvider).db,
        ownerId: ref.read(ingestionOrchestratorProvider).ownerId,
      ).persist(Map<String, dynamic>.from(decoded), sourceText: _controller.text);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Imported successfully. $result')),
      );
    } catch (error, stackTrace) {
      messenger.showSnackBar(
        rawErrorSnackBar(
          'Import failed',
          error: error,
          stackTrace: stackTrace,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import JSON')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _copySchema,
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy Schema to Clipboard'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Paste structured JSON here',
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _busy ? null : _import,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_done_rounded),
                label: const Text('Import to Database'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
