import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppStorage {
  AppStorage._();
  static final AppStorage instance = AppStorage._();

  late final Directory _dataDir;
  late final Directory _photosDir;

  Future<void> init() async {
    final base = await getApplicationDocumentsDirectory();
    _dataDir = Directory(p.join(base.path, 'hematrack_data'));
    _photosDir = Directory(p.join(base.path, 'hematrack_photos'));
    await _dataDir.create(recursive: true);
    await _photosDir.create(recursive: true);
  }

  Future<void> writeJson(String name, dynamic data) async {
    final file = File(p.join(_dataDir.path, '$name.json'));
    await file.writeAsString(jsonEncode(data));
  }

  Future<dynamic> readJson(String name) async {
    final file = File(p.join(_dataDir.path, '$name.json'));
    if (!await file.exists()) return null;
    return jsonDecode(await file.readAsString());
  }

  Future<String> savePhoto(String sourcePath, String photoId) async {
    final ext = p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath);
    final dest = File(p.join(_photosDir.path, '$photoId$ext'));
    await File(sourcePath).copy(dest.path);
    return dest.path;
  }
}
