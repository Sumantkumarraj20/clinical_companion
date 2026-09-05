import 'package:web/web.dart' as web;

Future<String> saveCsvFile(String filename, String content) async {
  final href = 'data:text/csv;charset=utf-8,${Uri.encodeComponent(content)}';
  final anchor = web.HTMLAnchorElement()
    ..href = href
    ..download = filename
    ..style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  return filename;
}
