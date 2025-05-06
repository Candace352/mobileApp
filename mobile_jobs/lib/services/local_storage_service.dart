import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LocalStorageService {
  static Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    await Hive.openBox('resumes');
    await Hive.openBox('job_drafts');
    await Hive.openBox('favorites');
  }

  static Future<void> saveResume(File file, String key) async {
    final bytes = await file.readAsBytes();
    final box = Hive.box('resumes');
    await box.put(key, bytes);
  }

  static Future<File?> getResume(String key) async {
    final box = Hive.box('resumes');
    final bytes = box.get(key) as List<int>?;
    if (bytes == null) return null;
    
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$key');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }

  static Future<void> saveDraft(Map<String, dynamic> draft) async {
    final box = Hive.box('job_drafts');
    await box.put(DateTime.now().toString(), draft);
  }

  static Future<List<Map<String, dynamic>>> getDrafts() async {
    final box = Hive.box('job_drafts');
    return box.values.cast<Map<String, dynamic>>().toList();
  }

  static Future<void> toggleFavorite(String jobId) async {
    final box = Hive.box('favorites');
    final favorites = box.get('favorites', defaultValue: <String>[]) as List<String>;
    
    if (favorites.contains(jobId)) {
      favorites.remove(jobId);
    } else {
      favorites.add(jobId);
    }
    
    await box.put('favorites', favorites);
  }

  static Future<bool> isFavorite(String jobId) async {
    final box = Hive.box('favorites');
    final favorites = box.get('favorites', defaultValue: <String>[]) as List<String>;
    return favorites.contains(jobId);
  }
}