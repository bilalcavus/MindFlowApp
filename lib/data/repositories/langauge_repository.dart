import 'package:mind_flow/core/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class LanguageRepository {
  final DatabaseService _dbService = DatabaseService();
  

  Future<void> saveLanguagePreference(String languageCode, String userId) async {
  final dbClient = await _dbService.database;
  final now = DateTime.now().toIso8601String();

  await dbClient.insert(
    'user_preferences',
    {
      'user_id': userId,
      'preference_key': 'language_code',
      'preference_value': languageCode,
      'updated_at': now,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<String?> getSavedLanguagePreference(String userId) async {
  final dbClient = await _dbService.database;

  final result = await dbClient.query(
    'user_preferences',
    where: 'user_id = ? AND preference_key = ?',
    whereArgs: [userId, 'language_code'],
    limit: 1,
  );

  if (result.isNotEmpty) {
    return result.first['preference_value'] as String;
  }

  return null;
}
}