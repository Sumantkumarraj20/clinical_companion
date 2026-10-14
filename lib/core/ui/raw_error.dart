import 'package:flutter/material.dart';

/// Unfiltered technical description: `error.toString()` plus the stack trace.
String describeRawError(Object error, [StackTrace? stackTrace]) {
  final buffer = StringBuffer('${error.runtimeType}: $error');
  if (stackTrace != null) {
    buffer.write('\n\nStack trace:\n$stackTrace');
  }
  return buffer.toString();
}

/// Scrollable, selectable text block that never grows past [maxHeight].
class SelectableErrorText extends StatelessWidget {
  const SelectableErrorText(
    this.text, {
    super.key,
    this.maxHeight = 240,
    this.style,
  });

  final String text;
  final double maxHeight;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: SelectableText(
            text,
            style: style ?? const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}

/// SnackBar with selectable, bounded text, a 10 s lifetime and a Dismiss
/// action. Use for failures so the raw error can be highlighted and copied.
SnackBar rawErrorSnackBar(
  String text, {
  Object? error,
  StackTrace? stackTrace,
  Duration duration = const Duration(seconds: 10),
}) {
  if (error != null) text = '$text\n\n${describeRawError(error, stackTrace)}';
  return SnackBar(
    duration: duration,
    content: SelectableErrorText(
      text,
      maxHeight: 200,
      style: const TextStyle(fontSize: 12, color: Colors.white),
    ),
    action: SnackBarAction(
      label: 'Dismiss',
      onPressed: () {},
      textColor: Colors.white,
    ),
  );
}

void showRawErrorSnackBar(ScaffoldMessengerState? messenger, String text) {
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(rawErrorSnackBar(text));
}
