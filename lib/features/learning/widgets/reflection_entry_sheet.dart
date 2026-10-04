import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';

/// A single reflection capture form.
///
/// Sprint 15 — Phase 2's private learning loop.
///
/// Deliberately a *private* space: this is the clinician's own reasoning about
/// their decision, not part of the patient's chart. It is never enqueued for
/// sync, never shown to another clinician on a shared device, and must not be
/// read by the Phase 2 cohort/audit exporter. The header says so explicitly so
/// nobody assumes it is part of the medical record.
class ReflectionEntrySheet extends ConsumerStatefulWidget {
  const ReflectionEntrySheet({
    required this.patientId,
    this.encounterId,
    super.key,
  });

  final String patientId;
  final String? encounterId;

  /// Opens the sheet. Resolves to true when a reflection was saved.
  static Future<bool> show(
    BuildContext context, {
    required String patientId,
    String? encounterId,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          ReflectionEntrySheet(patientId: patientId, encounterId: encounterId),
    );
    return saved ?? false;
  }

  @override
  ConsumerState<ReflectionEntrySheet> createState() =>
      _ReflectionEntrySheetState();
}

class _ReflectionEntrySheetState extends ConsumerState<ReflectionEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  final _differentials = TextEditingController();
  final _rationale = TextEditingController();
  final _takeaway = TextEditingController();

  /// Sprint 16 — a dedicated tag field. Typing `#hyponatremia` and a space
  /// commits it; the chip strip gives immediate feedback and prevents a typo
  /// from silently going unsearchable.
  final _tagInput = TextEditingController();
  final List<String> _tags = [];

  /// 1–10, defaulting to a neutral 5 rather than 7: an inflated default would
  /// quietly bias every clinician's calibration data.
  int _confidence = 5;
  bool _saving = false;

  /// Commits whatever is in the tag box when the clinician types a space or
  /// commits the field, and strips the `#` so `#a #b` and `a b` behave alike.
  void _commitTag() {
    final raw = _tagInput.text.trim().replaceFirst('#', '').trim();
    if (raw.isEmpty) return;
    final tag = raw.toLowerCase();
    if (tag.length < 2 || tag.length > 32 || _tags.contains(tag)) {
      _tagInput.clear();
      return;
    }
    setState(() {
      _tags.add(tag);
      // Reflect the committed tag back into the text so the clinician sees
      // exactly what was captured.
      _tagInput.text = '#$tag ';
    });
  }

  @override
  void dispose() {
    _differentials.dispose();
    _rationale.dispose();
    _takeaway.dispose();
    _tagInput.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(clinicalDaoProvider)
          .saveReflection(
            patientId: widget.patientId,
            encounterId: widget.encounterId,
            confidenceScore: _confidence,
            // Tags are merged into the prose the DAO persists, so the stored
            // text and the searchable tag column can never disagree.
            differentialDiagnoses:
                '${_differentials.text}\n${_tags.map((t) => '#$t').join(' ')}',
            decisionRationale: _rationale.text,
            clinicalTakeaway: _takeaway.text,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save reflection: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  bool get _allEmpty =>
      _rationale.text.trim().isEmpty &&
      _differentials.text.trim().isEmpty &&
      _takeaway.text.trim().isEmpty;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      // Lift the sheet above the soft keyboard so Save stays reachable.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Log Reflection', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Private to you. Not part of the medical record, never shared.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Confidence in your leading diagnosis: $_confidence / 10',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Slider(
                value: _confidence.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: '$_confidence',
                semanticFormatterCallback: (value) =>
                    'Confidence ${value.round()} out of 10',
                onChanged: (value) =>
                    setState(() => _confidence = value.round()),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _differentials,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Differentials you seriously considered',
                  hintText: 'e.g. Perforated peptic ulcer, LBO...',
                  border: OutlineInputBorder(),
                ),
                // At least one substantive field must be filled: an empty
                // reflection is noise in a dataset meant to train judgement.
                validator: (_) => _allEmpty
                    ? 'Write at least one of the three fields.'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _rationale,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Why this diagnosis?',
                  hintText: 'What supported it, and what argued against it.',
                  border: OutlineInputBorder(),
                ),
                validator: (_) => _allEmpty
                    ? 'Write at least one of the three fields.'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _takeaway,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'What would you do differently?',
                  hintText: 'The honest part - future you benefits most.',
                  border: OutlineInputBorder(),
                ),
                validator: (_) => _allEmpty
                    ? 'Write at least one of the three fields.'
                    : null,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _tagInput,
                decoration: const InputDecoration(
                  labelText: 'Tags (#hashtags)',
                  hintText: '#hyponatremia #renal',
                  prefixIcon: Icon(Icons.tag),
                  border: OutlineInputBorder(),
                ),
                // Typing a space commits the tag; pasting several also works.
                onChanged: (value) {
                  if (value.endsWith(' ') || value.endsWith(',')) _commitTag();
                },
                onSubmitted: (_) => _commitTag(),
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final tag in _tags)
                      InputChip(
                        label: Text('#$tag'),
                        onDeleted: () => setState(() => _tags.remove(tag)),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(_saving ? 'Saving...' : 'Save Reflection'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
