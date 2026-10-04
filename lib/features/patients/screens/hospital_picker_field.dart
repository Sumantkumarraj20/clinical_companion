import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';

/// Hospital / clinic dropdown with inline creation.
///
/// Sprint 14.5 — a clinician working across several institutions could not
/// register a new facility from the form, so a patient seen at a second
/// hospital had to be filed under whichever facility happened to be listed
/// first. That silently corrupted multi-hospital tracking.
///
/// Choosing "Add New Hospital / Clinic..." prompts for a name, inserts the row
/// into [Hospitals] and selects it immediately.
class HospitalPickerField extends ConsumerStatefulWidget {
  const HospitalPickerField({
    required this.selectedId,
    required this.onChanged,
    this.labelText = 'Hospital / Clinic',
    super.key,
  });

  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final String labelText;

  static const String addNewSentinel = '__add_new_hospital__';

  @override
  ConsumerState<HospitalPickerField> createState() =>
      _HospitalPickerFieldState();
}

class _HospitalPickerFieldState extends ConsumerState<HospitalPickerField> {
  List<Hospital> _hospitals = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dao = ref.read(clinicalDaoProvider);
    final active = await (dao.select(
      dao.hospitals,
    )..where((t) => t.isActive.equals(true))).get();

    if (!mounted) return;
    setState(() {
      _hospitals = active;
      _loading = false;
      // Default to the first facility so a new record is never saved with no
      // hospital context at all.
      if (widget.selectedId == null && active.isNotEmpty) {
        widget.onChanged(active.first.id);
      }
    });
  }

  Future<void> _createAndSelect() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _NewHospitalDialog(),
    );
    if (name == null || name.trim().isEmpty || !mounted) return;

    final dao = ref.read(clinicalDaoProvider);
    final created = await dao.createHospital(name.trim());
    if (!mounted) return;

    setState(() => _hospitals = [..._hospitals, created]);
    // Selecting it immediately means the clinician never has to re-open the
    // dropdown to confirm the new facility registered.
    widget.onChanged(created.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${created.name} added')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _hospitals.any((h) => h.id == widget.selectedId)
          ? widget.selectedId
          : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: const Icon(Icons.local_hospital_outlined),
      ),
      items: [
        for (final hospital in _hospitals)
          DropdownMenuItem(
            value: hospital.id,
            child: Text(
              hospital.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const DropdownMenuItem(
          value: HospitalPickerField.addNewSentinel,
          child: Row(
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Add New Hospital / Clinic...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        if (value == null) return;
        if (value == HospitalPickerField.addNewSentinel) {
          _createAndSelect();
          return;
        }
        widget.onChanged(value);
      },
    );
  }
}

/// Minimal prompt for the new facility's name.
class _NewHospitalDialog extends StatefulWidget {
  const _NewHospitalDialog();

  @override
  State<_NewHospitalDialog> createState() => _NewHospitalDialogState();
}

class _NewHospitalDialogState extends State<_NewHospitalDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Hospital / Clinic'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Facility name',
          hintText: 'e.g. City General Hospital',
        ),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
