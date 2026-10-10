import 'package:flutter/material.dart';

import '../../../core/clinical/note_formatter.dart';
import '../../../core/database/local_database.dart';
import '../../../core/widgets/copy_note_button.dart';

/// Editable Procedure / OT note templates, pre-filled from patient data.
class NoteTemplatesScreen extends StatefulWidget {
  const NoteTemplatesScreen({super.key, this.patient, this.diagnosis});

  final Patient? patient;
  final String? diagnosis;

  @override
  State<NoteTemplatesScreen> createState() => _NoteTemplatesScreenState();
}

class _NoteTemplatesScreenState extends State<NoteTemplatesScreen> {
  NoteTemplate _template = NoteTemplate.procedure;
  final Map<String, TextEditingController> _c = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    for (final c in _c.values) {
      c.dispose();
    }
    _c.clear();
    final known = widget.patient == null
        ? <String, String>{}
        : NoteTemplate.prefill(
            patient: widget.patient!,
            diagnosis: widget.diagnosis,
          );
    for (final f in _template.fields) {
      _c[f.key] = TextEditingController(text: known[f.key] ?? '');
    }
    if (widget.patient == null) {
      final now = DateTime.now();
      _c['date']?.text = '${now.day}/${now.month}/${now.year}';
    }
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _text() =>
      _template.render({for (final e in _c.entries) e.key: e.value.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Procedure and OT notes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<NoteTemplate>(
            segments: [
              for (final t in NoteTemplate.all)
                ButtonSegment(value: t, label: Text(t.title)),
            ],
            selected: {_template},
            onSelectionChanged: (s) => setState(() {
              _template = s.first;
              _load();
            }),
          ),
          const SizedBox(height: 16),
          for (final f in _template.fields)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _c[f.key],
                minLines: 1,
                maxLines: f.lines + 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: f.label,
                  hintText: f.hint.isEmpty ? null : f.hint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          const SizedBox(height: 8),
          CopyNoteButton(textBuilder: _text, label: 'Copy note', filled: true),
          const SizedBox(height: 8),
          Text(
            'Review and complete every field before you rely on this note.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
