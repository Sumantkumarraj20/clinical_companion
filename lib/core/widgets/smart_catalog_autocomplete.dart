import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

/// Generic smart autocomplete backed by offline-first sources.
///
/// * `category: 'medication'` → learned catalog first, then drug_master.
/// * `category: 'procedure'` → learned catalog first, then PM-JAY HBP.
/// Call [SmartCatalogHelper.recordUsage] when an order is finalized so
/// frequency weights improve future 2-letter suggestions.
class SmartAutocomplete<T extends Object> extends ConsumerWidget {
  const SmartAutocomplete({
    required this.category,
    required this.controller,
    required this.labelText,
    required this.optionsLoader,
    required this.displayString,
    this.hintText,
    this.prefixIcon,
    this.onSelected,
    this.validator,
    this.isDense = true,
    super.key,
  });

  final String category;
  final TextEditingController controller;
  final String labelText;
  final Future<List<T>> Function(String query) optionsLoader;
  final String Function(T option) displayString;
  final String? hintText;
  final IconData? prefixIcon;
  final ValueChanged<T>? onSelected;
  final String? Function(String?)? validator;
  final bool isDense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(clinicalDaoProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return RawAutocomplete<T>(
          textEditingController: controller,
          focusNode: FocusNode(),
          displayStringForOption: displayString,
          optionsBuilder: (TextEditingValue textEditingValue) async {
            final query = textEditingValue.text.trim();
            if (query.length < 2) return Iterable<T>.empty();
            final remote = await optionsLoader(query);
            if (T == String) {
              final learned = await dao.searchLearnedCatalog(
                category: category,
                query: query,
              );
              final seen = remote.map(displayString).toSet();
              final extras = learned.where((s) => seen.add(s)).cast<T>();
              return [...extras, ...remote];
            }
            return remote;
          },
          onSelected: onSelected,
          fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: textController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: labelText,
                hintText: hintText,
                isDense: isDense,
                prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
              ),
              validator: validator,
            );
          },
          optionsViewBuilder: (context, onAutoCompleteSelect, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth,
                    maxHeight: 220,
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.history, size: 16, color: Colors.teal),
                        title: Text(
                          displayString(option),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        trailing: const Icon(Icons.north_west, size: 14, color: Colors.grey),
                        onTap: () => onAutoCompleteSelect(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class SmartCatalogAutocomplete extends ConsumerWidget {
  const SmartCatalogAutocomplete({
    required this.category,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.onSelected,
    this.validator,
    this.isDense = true,
    super.key,
  });

  /// Category tag, e.g. 'medication', 'procedure', 'investigation', 'diagnosis'
  final String category;
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final ValueChanged<String>? onSelected;
  final String? Function(String?)? validator;
  final bool isDense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(clinicalDaoProvider);
    return SmartAutocomplete<String>(
      category: category,
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      validator: validator,
      displayString: (s) => s,
      onSelected: (selection) {
        controller.text = selection;
        onSelected?.call(selection);
      },
      optionsLoader: (query) async {
        if (category == 'medication') {
          final drugs = await dao.watchDrugs(query).first;
          return [
            for (final d in drugs)
              d.brandName?.trim().isNotEmpty == true
                  ? '${d.genericName} (${d.brandName})'
                  : d.genericName,
          ];
        }
        if (category == 'procedure') {
          final procedures = await dao.searchProcedures(query).first;
          return [
            for (final p in procedures)
              '${p.procedureName} [${p.procedureCode}]',
          ];
        }
        return const [];
      },
    );
  }
}

/// Save-to-catalog helper: call when an order is finalized.
class SmartCatalogHelper {
  static Future<void> recordUsage(
    WidgetRef ref, {
    required String category,
    required String term,
  }) => ref
      .read(clinicalDaoProvider)
      .recordCatalogUsage(category: category, term: term);
}