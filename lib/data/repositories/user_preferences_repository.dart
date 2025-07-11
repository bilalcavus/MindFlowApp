import 'package:flutter/foundation.dart';
import 'package:mind_flow/core/constants/api_constants.dart';
import 'package:mind_flow/core/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class UserPreferencesRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<int> setPreference(String userId, String key, String value) async {
    final db = await _dbService.database;
    final now = DateTime.now().toIso8601String();

    return await db.insert(
      'user_preferences',
      {
        'user_id': userId,
        'preference_key': key,
        'preference_value': value,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getPreference(String userId, String key) async {
    final db = await _dbService.database;
    final result = await db.query(
      'user_preferences',
      where: 'user_id = ? AND preference_key = ?',
      whereArgs: [userId, key],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['preference_value'] as String;
    }

    return null;
  }

  Future<int> setBoolPreference(String userId, String key, bool value) async {
    return await setPreference(userId, key, value.toString());
  }

  Future<bool> getBoolPreference(String userId, String key, {bool defaultValue = false}) async {
    final value = await getPreference(userId, key);
    return value != null ? value.toLowerCase() == 'true' : defaultValue;
  }

  Future<int> setIntPreference(String userId, String key, int value) async {
    return await setPreference(userId, key, value.toString());
  }

  Future<int> getIntPreference(String userId, String key, {int defaultValue = 0}) async {
    final value = await getPreference(userId, key);
    return value != null ? int.tryParse(value) ?? defaultValue : defaultValue;
  }

  Future<int> setDoublePreference(String userId, String key, double value) async {
    return await setPreference(userId, key, value.toString());
  }

  Future<double> getDoublePreference(String userId, String key, {double defaultValue = 0.0}) async {
    final value = await getPreference(userId, key);
    return value != null ? double.tryParse(value) ?? defaultValue : defaultValue;
  }

  Future<Map<String, String>> getAllPreferences(String userId) async {
    final db = await _dbService.database;
    final result = await db.query(
      'user_preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final preferences = <String, String>{};
    for (final row in result) {
      preferences[row['preference_key'] as String] = row['preference_value'] as String;
    }

    return preferences;
  }

  Future<int> removePreference(String userId, String key) async {
    final db = await _dbService.database;
    return await db.delete(
      'user_preferences',
      where: 'user_id = ? AND preference_key = ?',
      whereArgs: [userId, key],
    );
  }

  Future<int> clearAllPreferences(String userId) async {
    final db = await _dbService.database;
    return await db.delete(
      'user_preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<Map<String, String>> getPreferencesByPrefix(String userId, String prefix) async {
    final db = await _dbService.database;
    final result = await db.query(
      'user_preferences',
      where: 'user_id = ? AND preference_key LIKE ?',
      whereArgs: [userId, '$prefix%'],
    );

    final preferences = <String, String>{};
    for (final row in result) {
      final key = row['preference_key'] as String;
      final value = row['preference_value'] as String;
      preferences[key] = value;
    }

    return preferences;
  }

  Future<int> removePreferencesByPrefix(String userId, String prefix) async {
    final db = await _dbService.database;
    return await db.delete(
      'user_preferences',
      where: 'user_id = ? AND preference_key LIKE ?',
      whereArgs: [userId, '$prefix%'],
    );
  }

  Future<List<Map<String, dynamic>>> getPreferenceHistory({required String userId, int? limit}) async {
    final db = await _dbService.database;
    final result = await db.query(
      'user_preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
      limit: limit,
    );

    return result;
  }

  static const String prefSelectedModel = 'selected_model';
  static const String prefThemeMode = 'theme_mode';
  static const String prefAutoSaveEnabled = 'auto_save_enabled';
  static const String prefAnalysisHistoryLimit = 'analysis_history_limit';
  static const String prefNotificationsEnabled = 'notifications_enabled';
  static const String prefLanguage = 'language';
  static const String prefFontSize = 'font_size';
  static const String prefDataBackupEnabled = 'data_backup_enabled';
  static const String prefLastBackupDate = 'last_backup_date';
  static const String prefAnalyticsEnabled = 'analytics_enabled';

  Future<String> getSelectedModel(String userId) async {
    return await getPreference(userId, prefSelectedModel) ?? ApiConstants.defaultModel;
  }

  Future<int> setSelectedModel(String userId, String model) async {
    return await setPreference(userId, prefSelectedModel, model);
  }

  Future<String> getThemeMode(String userId) async {
    return await getPreference(userId, prefThemeMode) ?? 'dark';
  }

  Future<int> setThemeMode(String userId, String themeMode) async {
    return await setPreference(userId, prefThemeMode, themeMode);
  }

  Future<bool> isAutoSaveEnabled(String userId) async {
    return await getBoolPreference(userId, prefAutoSaveEnabled, defaultValue: true);
  }

  Future<int> setAutoSaveEnabled(String userId, bool enabled) async {
    return await setBoolPreference(userId, prefAutoSaveEnabled, enabled);
  }

  Future<int> getAnalysisHistoryLimit(String userId) async {
    return await getIntPreference(userId, prefAnalysisHistoryLimit, defaultValue: 50);
  }

  Future<int> setAnalysisHistoryLimit(String userId, int limit) async {
    return await setIntPreference(userId, prefAnalysisHistoryLimit, limit);
  }

  Future<bool> areNotificationsEnabled(String userId) async {
    return await getBoolPreference(userId, prefNotificationsEnabled, defaultValue: true);
  }

  Future<int> setNotificationsEnabled(String userId, bool enabled) async {
    return await setBoolPreference(userId, prefNotificationsEnabled, enabled);
  }

  Future<String> getLanguage(String userId) async {
    return await getPreference(userId, prefLanguage) ?? 'en';
  }

  Future<int> setLanguage(String userId, String language) async {
    return await setPreference(userId, prefLanguage, language);
  }

  Future<double> getFontSize(String userId) async {
    return await getDoublePreference(userId, prefFontSize, defaultValue: 14.0);
  }

  Future<int> setFontSize(String userId, double fontSize) async {
    return await setDoublePreference(userId, prefFontSize, fontSize);
  }

  Future<bool> isDataBackupEnabled(String userId) async {
    return await getBoolPreference(userId, prefDataBackupEnabled, defaultValue: true);
  }

  Future<int> setDataBackupEnabled(String userId, bool enabled) async {
    return await setBoolPreference(userId, prefDataBackupEnabled, enabled);
  }

  Future<DateTime?> getLastBackupDate(String userId) async {
    final dateString = await getPreference(userId, prefLastBackupDate);
    return dateString != null ? DateTime.tryParse(dateString) : null;
  }

  Future<int> setLastBackupDate(String userId, DateTime date) async {
    return await setPreference(userId, prefLastBackupDate, date.toIso8601String());
  }

  Future<bool> isAnalyticsEnabled(String userId) async {
    return await getBoolPreference(userId, prefAnalyticsEnabled, defaultValue: true);
  }

  Future<int> setAnalyticsEnabled(String userId, bool enabled) async {
    return await setBoolPreference(userId, prefAnalyticsEnabled, enabled);
  }

  Future<void> createDefaultPreferences(String userId) async {

    final defaultPrefs = [
      {'key': prefSelectedModel, 'value': ApiConstants.defaultModel},
      {'key': prefThemeMode, 'value': 'dark'},
      {'key': prefAutoSaveEnabled, 'value': 'true'},
      {'key': prefAnalysisHistoryLimit, 'value': '50'},
      {'key': prefNotificationsEnabled, 'value': 'true'},
      {'key': prefLanguage, 'value': 'en'},
      {'key': prefFontSize, 'value': '14.0'},
      {'key': prefDataBackupEnabled, 'value': 'true'},
      {'key': prefAnalyticsEnabled, 'value': 'true'},
    ];

    for (final pref in defaultPrefs) {
      await setPreference(userId, pref['key']!, pref['value']!);
    }

    debugPrint('✅ Varsayılan tercihler oluşturuldu (User ID: $userId)');
  }

  Future<void> resetToDefaults(String userId) async {
    await clearAllPreferences(userId);
    await createDefaultPreferences(userId);
    debugPrint('✅ Tercihler varsayılana sıfırlandı (User ID: $userId)');
  }
} 