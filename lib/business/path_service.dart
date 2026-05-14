import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PathService {
  static late final String appDocPath;
  static late final String ankiPath;

  /// Initializes the base paths for the application.
  /// Must be called before accessing any paths.
  static Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    appDocPath = directory.path;
    ankiPath = p.join(appDocPath, 'anki');
    
    // Ensure the anki directory exists
    final ankiDir = Directory(ankiPath);
    if (!await ankiDir.exists()) {
      await ankiDir.create(recursive: true);
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
