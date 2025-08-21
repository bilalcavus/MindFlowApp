import 'package:flutter/material.dart';
import 'package:mind_flow/core/services/database_service.dart';
import 'package:mind_flow/injection/injection.dart';

Future<void> initializeDatabase() async {
  try {
    final dbService = getIt<DatabaseService>();
    await dbService.database;
    debugPrint('Local database initialize edildi');
    await dbService.createMissingTables();
  } catch (e) {
    debugPrint('Veritabanı başlatma hatası: $e');
  }
}
