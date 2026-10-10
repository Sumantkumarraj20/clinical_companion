import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ai/document_ai_service.dart';
import '../../../core/database/local_database.dart';
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
  bool _processAsGuideline = false;
  List<CachedClinicalRule> _guidelineRules = const [];

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
      if (_processAsGuideline) {
        final suggestions = await ref
            .read(documentAiServiceProvider)
            .generateClinicalRulesFromGuideline(
              text,
              // Sprint 27 (adaptive compute): mining contraindication and
              // monitoring rules from literature is a Multi-Variable
              // Guardrails task (Sprint 24) — `high`.
              thinkingLevel: ThinkingLevel.high,
            );
        final result = await ref
            .read(clinicalRuleDaoProvider)
            .saveGuidelineRules(suggestions);
        if (!mounted) return;
        setState(() => _guidelineRules = result.rules);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              suggestions.isEmpty
                  ? 'No supported clinical pathways were found in this text.'
                  : 'Saved ${result.insertedCount} new rule'
                        '${result.insertedCount == 1 ? '' : 's'}. '
                        'Review each suggestion before it becomes active.',
            ),
          ),
        );
        return;
      }
      final census = await BatchExtractionNotifier.buildActiveCensusJson(
        ref.read(clinicalDaoProvider),
      );
      if (!mounted) return;
      ref
          .read(batchExtractionProvider.notifier)
          .addOmniText(text, activeCensusJson: census);
      context.go('/dashboard');
    } catch (error, stackTrace) {
      debugPrint('Could not prepare pasted clinical text: $error\n$stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not prepare this text. Your original text is still here; please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _reviewRule(CachedClinicalRule rule, {required bool accept}) async {
    try {
      final dao = ref.read(clinicalRuleDaoProvider);
      if (accept) {
        final verified = await dao.verifyRule(rule.id);
        if (mounted) {
          setState(() {
            _guidelineRules = [
              for (final item in _guidelineRules)
                if (item.id == rule.id) verified else item,
            ];
          });
        }
      } else {
        await dao.dismissRule(rule.id);
        if (mounted) {
          setState(
            () => _guidelineRules = _guidelineRules
                .where((item) => item.id != rule.id)
                .toList(growable: false),
          );
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Could not update clinical pathway: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update this pathway. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canProcess = !_submitting && _textController.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Paste Clinical Text')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: canProcess ? _processText : null,
        icon: _submitting
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(_submitting ? 'Preparing…' : 'Prepare for review'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _processAsGuideline
                    ? 'Paste guideline or trial text to identify clinical '
                          'pathways for your review.'
                    : 'Paste clinical text from an EHR, message, or note. '
                          'It will be organized into a clinical note for your review.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Process as Clinical Guideline'),
                subtitle: Text(
                  _processAsGuideline
                      ? 'Extract reusable rules; no patient record is created.'
                      : 'Process as Patient Data',
                ),
                value: _processAsGuideline,
                onChanged: _submitting
                    ? null
                    : (enabled) =>
                          setState(() => _processAsGuideline = enabled),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      flex: _guidelineRules.isEmpty ? 1 : 3,
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
                    if (_guidelineRules.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Expanded(
                        flex: 2,
                        child: ListView(
                          children: [
                            for (final rule in _guidelineRules)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${rule.triggerType}: ${rule.triggerValue}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(rule.suggestedAction),
                                      if (rule.contraindicatingConditions
                                          .isNotEmpty)
                                        Text(
                                          'Do not proceed: ${rule.contraindicatingConditions.join('; ')}',
                                        ),
                                      if (rule.requiredMonitoring.isNotEmpty)
                                        Text(
                                          'Monitor: ${rule.requiredMonitoring.join('; ')}',
                                        ),
                                      if (rule.sourceReference
                                          .trim()
                                          .isNotEmpty)
                                        Text('Source: ${rule.sourceReference}'),
                                      if (!rule.isVerified)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () => _reviewRule(
                                                rule,
                                                accept: false,
                                              ),
                                              child: const Text('Dismiss'),
                                            ),
                                            FilledButton.tonal(
                                              onPressed: () => _reviewRule(
                                                rule,
                                                accept: true,
                                              ),
                                              child: const Text('Verify rule'),
                                            ),
                                          ],
                                        )
                                      else
                                        const Text('Verified and active'),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
