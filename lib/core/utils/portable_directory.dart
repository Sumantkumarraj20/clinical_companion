import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<Directory> getPortableStorageDirectory() async {
  final baseDirectory = Platform.isWindows || Platform.isLinux || Platform.isMacOS
      ? File(Platform.resolvedExecutable).parent
      : await getApplicationDocumentsDirectory();
  final storageDirectory = Directory(
    path.join(baseDirectory.path, 'clinical_data'),
  );
  await storageDirectory.create(recursive: true);
  return storageDirectory;
}