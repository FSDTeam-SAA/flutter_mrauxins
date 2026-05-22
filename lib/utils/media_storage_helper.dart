import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class MediaStorageHelper {
  static Future<String> getMediaDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDir.path}/media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    return mediaDir.path;
  }

  static Future<String> saveMediaFile(XFile file) async {
    final mediaDir = await getMediaDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final persistentPath = '$mediaDir/$fileName';

    // For iOS, we need to copy the file to persistent storage
    if (Platform.isIOS) {
      final sourceFile = File(file.path);
      await sourceFile.copy(persistentPath);
    } else {
      await file.saveTo(persistentPath);
    }

    return persistentPath;
  }

  static Future<void> cleanupOldFiles({int daysToKeep = 7}) async {
    final mediaDir = await getMediaDirectory();
    final directory = Directory(mediaDir);
    final now = DateTime.now();

    if (await directory.exists()) {
      final files = await directory.list().toList();

      for (final file in files) {
        final stat = await file.stat();
        if (now.difference(stat.modified) > Duration(days: daysToKeep)) {
          await file.delete();
        }
      }
    }
  }
}
