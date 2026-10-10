import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One-tap copy of plain text for pasting into another record system.
class CopyNoteButton extends StatelessWidget {
  const CopyNoteButton({
    super.key,
    required this.textBuilder,
    this.label = 'Copy',
    this.filled = false,
  });

  /// Evaluated at tap time so the latest edits are always copied.
  final String Function() textBuilder;
  final String label;
  final bool filled;

  Future<void> _copy(BuildContext context) async {
    final text = textBuilder().trim();
    final messenger = ScaffoldMessenger.of(context);
    if (text.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Nothing to copy yet.')),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Copied. Ready to paste.')));
  }

  @override
  Widget build(BuildContext context) {
    const icon = Icon(Icons.copy_all_outlined);
    return filled
        ? FilledButton.icon(
            onPressed: () => _copy(context),
            icon: icon,
            label: Text(label),
          )
        : OutlinedButton.icon(
            onPressed: () => _copy(context),
            icon: icon,
            label: Text(label),
          );
  }
}
