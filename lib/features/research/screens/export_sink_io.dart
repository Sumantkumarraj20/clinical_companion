import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> saveCsvFile(String filename, String content) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File(p.join(directory.path, filename));
  await file.writeAsString(content, flush: true);
  return file.path;
}
