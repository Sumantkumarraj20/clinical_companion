import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';

class TextIngestionScreen extends ConsumerStatefulWidget {
  const TextIngestionScreen({super.key});

  @override
  ConsumerState<TextIngestionScreen> createState() =>
      _TextIngestionScreenState();
}

class _TextIngestionScreenState extends ConsumerState<TextIngestionScreen> {
  final _textController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _processText() async {
    final text = _textController.text;
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paste or type clinical text first.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final census = await BatchExtractionNotifier.buildActiveCensusJson(
        ref.read(clinicalDaoProvider),
      );
      if (!mounted) return;
      ref
          .read(batchExtractionProvider.notifier)
          .addText(text, activeCensusJson: census);
      context.push('/adaptive-review');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not prepare text for ClinCom: $error')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canProcess = !_submitting && _textController.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Paste')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: canProcess ? _processText : null,
        icon: _submitting
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(_submitting ? 'Preparing…' : 'Process with ClinCom'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Paste clinical text from an EHR, message, or note. '
                'ClinCom will organize it for your review.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: _textController,
                  autofocus: true,
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Paste or type unstructured clinical text…',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
