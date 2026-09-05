import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../core/utils/portable_directory.dart';

Future<String> saveCsvFile(String filename, String content) async {
  final directory = await getPortableStorageDirectory();
  final file = File(p.join(directory.path, filename));
  await file.writeAsString(content, flush: true);
  return file.path;
}
