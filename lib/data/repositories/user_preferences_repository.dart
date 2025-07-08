import 'package:mind_flow/core/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class UserPreferencesRepository {
  final DatabaseService _dbService = DatabaseService();

  // Tercih kaydetme veya güncelleme
  Future<int> setPreference(int userId, String key, String value) async {
    final db = await _dbService.database;
    final now = DateTime.now().toIso8601String();

    final existing = await getPreference(userId, key);
    
    if (existing != null) {
      return await db.update(
        'user_preferences',
        {
          'preference_value': value,
          'updated_at': now,
        },
        where: 'user_id = ? AND preference_key = ?',
        whereArgs: [userId, key],
      );
    } else {
      return await db.insert(
        'user_preferences',
        {
          'user_id': userId,
          'preference_key': key,
          'preference_value': value,
          'updated_at': now,
        },
      );
    }
  }

  // Tercih getirme
  Future<String?> getPreference(int userId, String key) async {
    final db = await _dbService.database;
    final results = await db.query(
      'user_preferences',
      where: 'user_id = ? AND preference_key = ?',
      whereArgs: [userId, key],
    );

    return results.isNotEmpty ? results.first['preference_value'] as String : null;
  }

  // Boolean tercih kaydetme
  Future<int> setBoolPreference(int userId, String key, bool value) async {
    return await setPreference(userId, key, value.toString());
  }

  // Boolean tercih getirme
  Future<bool> getBoolPreference(int userId, String key, {bool defaultValue = false}) async {
    final value = await getPreference(userId, key);
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  // Integer tercih kaydetme
  Future<int> setIntPreference(int userId, String key, int value) async {
    return await setPreference(userId, key, value.toString());
  }

  // Integer tercih getirme
  Future<int> getIntPreference(int userId, String key, {int defaultValue = 0}) async {
    final value = await getPreference(userId, key);
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  // Double tercih kaydetme
  Future<int> setDoublePreference(int userId, String key, double value) async {
    return await setPreference(userId, key, value.toString());
  }

  // Double tercih getirme
  Future<double> getDoublePreference(int userId, String key, {double defaultValue = 0.0}) async {
    final value = await getPreference(userId, key);
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  // Tüm tercihleri getirme
  Future<Map<String, String>> getAllPreferences(int userId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'user_preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final preferences = <String, String>{};
    for (final row in results) {
      preferences[row['preference_key'] as String] = row['preference_value'] as String;
    }

    return preferences;
  }

  // Tercih silme
  Future<int> removePreference(int userId, String key) async {
    final db = await _dbService.database;
    return await db.delete(
      'user_preferences',
      where: 'user_id = ? AND preference_key = ?',
      whereArgs: [userId, key],
    );
  }

  // Kullanıcının tüm tercihlerini silme
  Future<int> clearAllPreferences(int userId) async {
    final db = await _dbService.database;
    return await db.delete(
      'user_preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Belirli prefix ile başlayan tercihleri getirme
  Future<Map<String, String>> getPreferencesByPrefix(int userId, String prefix) async {
    final db = await _dbService.database;
    final results = await db.query(
      'user_preferences',
      where: 'user_id = ? AND preference_key LIKE ?',
      whereArgs: [userId, '$prefix%'],
    );

    final preferences = <String, String>{};
    for (final row in results) {
      preferences[row['preference_key'] as String] = row['preference_value'] as String;
    }

    return preferences;
  }

  // Belirli prefix ile başlayan tercihleri silme
  Future<int> removePreferencesByPrefix(int userId, String prefix) async {
    final db = await _dbService.database;
    return await db.delete(
      'user_preferences',
      where: 'user_id = ? AND preference_key LIKE ?',
      whereArgs: [userId, '$prefix%'],
    );
  }

  // Önceden tanımlanmış tercih anahtarları
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

  // Yaygın kullanılan tercih metodları

  // Seçili model
  Future<String> getSelectedModel(int userId) async {
    return await getPreference(userId, prefSelectedModel) ?? 'mistral-small-3.2';
  }

  Future<int> setSelectedModel(int userId, String model) async {
    return await setPreference(userId, prefSelectedModel, model);
  }

  // Tema modu
  Future<String> getThemeMode(int userId) async {
    return await getPreference(userId, prefThemeMode) ?? 'dark';
  }

  Future<int> setThemeMode(int userId, String themeMode) async {
    return await setPreference(userId, prefThemeMode, themeMode);
  }

  // Otomatik kayıt
  Future<bool> isAutoSaveEnabled(int userId) async {
    return await getBoolPreference(userId, prefAutoSaveEnabled, defaultValue: true);
  }

  Future<int> setAutoSaveEnabled(int userId, bool enabled) async {
    return await setBoolPreference(userId, prefAutoSaveEnabled, enabled);
  }

  // Analiz geçmişi limiti
  Future<int> getAnalysisHistoryLimit(int userId) async {
    return await getIntPreference(userId, prefAnalysisHistoryLimit, defaultValue: 50);
  }

  Future<int> setAnalysisHistoryLimit(int userId, int limit) async {
    return await setIntPreference(userId, prefAnalysisHistoryLimit, limit);
  }

  // Bildirimler
  Future<bool> areNotificationsEnabled(int userId) async {
    return await getBoolPreference(userId, prefNotificationsEnabled, defaultValue: true);
  }

  Future<int> setNotificationsEnabled(int userId, bool enabled) async {
    return await setBoolPreference(userId, prefNotificationsEnabled, enabled);
  }

  // Dil ayarı
  Future<String> getLanguage(int userId) async {
    return await getPreference(userId, prefLanguage) ?? 'tr';
  }

  Future<int> setLanguage(int userId, String language) async {
    return await setPreference(userId, prefLanguage, language);
  }

  // Font boyutu
  Future<double> getFontSize(int userId) async {
    return await getDoublePreference(userId, prefFontSize, defaultValue: 14.0);
  }

  Future<int> setFontSize(int userId, double fontSize) async {
    return await setDoublePreference(userId, prefFontSize, fontSize);
  }

  // Veri yedekleme
  Future<bool> isDataBackupEnabled(int userId) async {
    return await getBoolPreference(userId, prefDataBackupEnabled, defaultValue: false);
  }

  Future<int> setDataBackupEnabled(int userId, bool enabled) async {
    return await setBoolPreference(userId, prefDataBackupEnabled, enabled);
  }

  // Son yedekleme tarihi
  Future<DateTime?> getLastBackupDate(int userId) async {
    final dateString = await getPreference(userId, prefLastBackupDate);
    return dateString != null ? DateTime.tryParse(dateString) : null;
  }

  Future<int> setLastBackupDate(int userId, DateTime date) async {
    return await setPreference(userId, prefLastBackupDate, date.toIso8601String());
  }

  // Analitik
  Future<bool> isAnalyticsEnabled(int userId) async {
    return await getBoolPreference(userId, prefAnalyticsEnabled, defaultValue: true);
  }

  Future<int> setAnalyticsEnabled(int userId, bool enabled) async {
    return await setBoolPreference(userId, prefAnalyticsEnabled, enabled);
  }

  // Kullanıcının varsayılan tercihlerini oluşturma
  Future<void> createDefaultPreferences(int userId) async {
    final db = await _dbService.database;
    final now = DateTime.now().toIso8601String();
    
    final defaultPrefs = [
      {'preference_key': prefSelectedModel, 'preference_value': 'mistral-small-3.2'},
      {'preference_key': prefThemeMode, 'preference_value': 'dark'},
      {'preference_key': prefAutoSaveEnabled, 'preference_value': 'true'},
      {'preference_key': prefAnalysisHistoryLimit, 'preference_value': '50'},
      {'preference_key': prefNotificationsEnabled, 'preference_value': 'true'},
      {'preference_key': prefLanguage, 'preference_value': 'tr'},
      {'preference_key': prefFontSize, 'preference_value': '14.0'},
      {'preference_key': prefDataBackupEnabled, 'preference_value': 'false'},
      {'preference_key': prefAnalyticsEnabled, 'preference_value': 'true'},
    ];

    for (final pref in defaultPrefs) {
      await db.insert(
        'user_preferences',
        {
          'user_id': userId,
          ...pref,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  // Kullanıcının tercihlerini varsayılana sıfırlama
  Future<void> resetToDefaults(int userId) async {
    await clearAllPreferences(userId);
    await createDefaultPreferences(userId);
  }

  // Tercih değişiklik geçmişi için
  Future<List<Map<String, dynamic>>> getPreferenceHistory({required int userId, int? limit}) async {
    final db = await _dbService.database;
    final results = await db.query(
      'user_preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
      limit: limit,
    );

    return results;
  }
} 