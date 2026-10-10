import 'dart:convert';
import 'dart:io';

import '../models/app_data.dart';

class StorageException implements Exception {
  StorageException(this.message);

  final String message;

  @override
  String toString() => 'StorageException: $message';
}

// Читає й записує дані у локальний файл JSON.
class DataRepository {
  DataRepository([this.path = 'data.json']);

  final String path;

  Future<AppData> load() async {
    final file = File(path);
    if (!await file.exists()) {
      return AppData();
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return AppData();
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Корінь файлу має бути JSON-обʼєктом.');
      }
      return AppData.fromJson(decoded);
    } on FormatException catch (e) {
      throw StorageException('Файл $path пошкоджено: ${e.message}');
    } on FileSystemException catch (e) {
      throw StorageException('Не вдалося прочитати $path: ${e.message}');
    }
  }

  Future<void> save(AppData data) async {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      await File(path).writeAsString(encoder.convert(data.toJson()));
    } on FileSystemException catch (e) {
      throw StorageException('Не вдалося записати $path: ${e.message}');
    }
  }
}
