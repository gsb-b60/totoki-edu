import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PathService {
  static late final String appDocPath;
  static late final String ankiPath;
  static String? initError;

  /// Initializes the base paths for the application.
  /// Must be called before accessing any paths.
  static Future<void> init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      appDocPath = directory.path;
      ankiPath = p.join(appDocPath, 'anki');

      final ankiDir = Directory(ankiPath);
      if (!await ankiDir.exists()) {
        await ankiDir.create(recursive: true);
      }
    } catch (e) {
      initError = 'Path init failed: $e';
      final tempDir = await getTemporaryDirectory();
      appDocPath = tempDir.path;
      ankiPath = p.join(appDocPath, 'anki');
    }
  }

  /// Returns the absolute path for a specific deck's media folder.
  static String getDeckMediaPath(String folderName) {
    return p.join(ankiPath, folderName);
  }

  /// Returns the absolute path for a specific file within a deck's media folder.
  static String getFilePath(String folderName, String fileName) {
    return p.join(ankiPath, folderName, fileName);
  }
}

