import 'dart:html' as html;

Future<String> saveCsvFile(String filename, String content) async {
  final href = 'data:text/csv;charset=utf-8,${Uri.encodeComponent(content)}';
  final anchor = html.AnchorElement(href: href)
    ..download = filename
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  return filename;
}
