import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

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

    return LayoutBuilder(
      builder: (context, constraints) {
        return RawAutocomplete<String>(
          textEditingController: controller,
          focusNode: FocusNode(),
          optionsBuilder: (TextEditingValue textEditingValue) async {
            final query = textEditingValue.text.trim();
            if (query.length < 2) return const Iterable<String>.empty();
            return await dao.searchLearnedCatalog(
              category: category,
              query: query,
            );
          },
          onSelected: (String selection) {
            controller.text = selection;
            onSelected?.call(selection);
          },
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
                          option,
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