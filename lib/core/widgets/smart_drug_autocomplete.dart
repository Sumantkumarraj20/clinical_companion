import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/clinical_drug_selection.dart';
import '../providers/app_providers.dart';

/// Token-efficient drug autocomplete backed by the ClinicalDrugs master table.
///
/// * Fires `pharmacopeiaDao.searchClinicalDrugs(term)` once the user has typed
///   more than 2 characters (debounced ~300ms to keep OPD/IPD ordering fast).
/// * Suggestions show the Generic Molecule as title, and Forms plus the top
///   Brands (when known) as subtitle — e.g. "Tablet · Augmentin (₹120)".
/// * On tap, hands the strongly-typed [ClinicalDrug] to [onSelected].
class SmartDrugAutocomplete extends ConsumerStatefulWidget {
  const SmartDrugAutocomplete({
    required this.controller,
    required this.onSelected,
    this.labelText = 'Drug',
    this.hintText,
    this.prefixIcon,
    this.validator,
    this.isDense = true,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<ClinicalDrugSelection> onSelected;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final bool isDense;

  @override
  ConsumerState<SmartDrugAutocomplete> createState() =>
      _SmartDrugAutocompleteState();
}

class _SmartDrugAutocompleteState extends ConsumerState<SmartDrugAutocomplete> {
  static const int _minQueryLength = 3;
  static const Duration _debounce = Duration(milliseconds: 300);

  @override
  void dispose() {
    _pendingQueries.clear();
    super.dispose();
  }

  // Queries awaiting their debounce window; keyed by the raw term so that a
  // fast typist only ever pays for the final term.
  final Map<String, Future<List<ClinicalDrugSelection>>> _pendingQueries = {};

  Future<List<ClinicalDrugSelection>> _debouncedSearch(String term) {
    return _pendingQueries.putIfAbsent(term, () {
      final future = Future<List<ClinicalDrugSelection>>(() async {
        await Future<void>.delayed(_debounce);
        _pendingQueries.remove(term);
        try {
          return await ref
              .read(pharmacopeiaDaoProvider)
              .searchClinicalDrugs(term);
        } catch (_) {
          return const [];
        }
      });
      return future;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<ClinicalDrugSelection>(
      textEditingController: widget.controller,
      displayStringForOption: (result) => result.molecule,
      optionsBuilder: (TextEditingValue value) {
        final query = value.text.trim();
        if (query.length < _minQueryLength) {
          return Future<List<ClinicalDrugSelection>>.value(const []);
        }
        return _debouncedSearch(query);
      },
      onSelected: widget.onSelected,
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: textController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            isDense: widget.isDense,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 20)
                : null,
          ),
          validator: widget.validator,
        );
      },
      optionsViewBuilder: (context, onSelect, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260, maxWidth: 420),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final result = options.elementAt(index);
                  final subtitle = result.subtitle;
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.medication_outlined,
                      size: 20,
                      color: Colors.teal,
                    ),
                    title: Text(
                      result.displayLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: subtitle.isEmpty
                        ? null
                        : Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    onTap: () => onSelect(result),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
