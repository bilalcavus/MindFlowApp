import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mind_flow/core/constants/api_constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mind_flow.db');

    return await openDatabase(
      path,
      version: 4, // Firebase UID migration için version 4
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        display_name TEXT NOT NULL,
        avatar_url TEXT,
        created_at TEXT NOT NULL,
        last_login_at TEXT,
        is_active INTEGER DEFAULT 1 CHECK (is_active IN (0, 1)),
        user_preferences_json TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        content TEXT NOT NULL,
        entry_type TEXT NOT NULL CHECK (entry_type IN (
          'emotion', 'dream', 'personality', 'habit', 'mental', 'stress'
        )),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        model_used TEXT,
        is_analyzed INTEGER DEFAULT 0 CHECK (is_analyzed IN (0, 1)),
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE emotion_analyses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        entry_id INTEGER NOT NULL,
        analysis_type TEXT NOT NULL CHECK (analysis_type IN (
          'emotion', 'personality', 'habit', 'mental', 'stress'
        )),
        emotions_json TEXT NOT NULL,
        emotion_reasoning_json TEXT,
        themes_json TEXT NOT NULL,
        summary TEXT NOT NULL,
        advice TEXT NOT NULL,
        ai_reply TEXT,
        mind_map_json TEXT NOT NULL,
        model_used TEXT NOT NULL,
        analysis_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (entry_id) REFERENCES user_entries (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE dream_analyses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        entry_id INTEGER NOT NULL,
        analysis_type TEXT NOT NULL DEFAULT 'dream',
        symbols_json TEXT NOT NULL,
        symbol_meanings_json TEXT NOT NULL,
        emotion_scores_json TEXT NOT NULL,
        themes_json TEXT NOT NULL,
        subconscious_message TEXT NOT NULL,
        summary TEXT NOT NULL,
        advice TEXT NOT NULL,
        ai_reply TEXT NOT NULL,
        mind_map_json TEXT NOT NULL,
        model_used TEXT NOT NULL,
        analysis_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (entry_id) REFERENCES user_entries (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        message TEXT NOT NULL,
        message_type TEXT NOT NULL CHECK (message_type IN ('user', 'ai')),
        timestamp TEXT NOT NULL,
        model_used TEXT,
        analysis_data_json TEXT,
        session_id TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE user_preferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        preference_key TEXT NOT NULL,
        preference_value TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(user_id, preference_key)
      )
    ''');

    await db.execute('''
      CREATE TABLE analysis_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        analysis_type TEXT NOT NULL,
        model_used TEXT NOT NULL,
        success_count INTEGER DEFAULT 0,
        error_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(user_id, date, analysis_type, model_used)
      )
    ''');

    await db.execute('''
      CREATE TABLE user_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        session_token TEXT UNIQUE NOT NULL,
        device_info TEXT,
        ip_address TEXT,
        created_at TEXT NOT NULL,
        expires_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 1 CHECK (is_active IN (0, 1)),
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute(''' 
      CREATE TABLE languages(
        id INTEGER PRIMARY KEY,
        code TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_users_email ON users (email)
    ''');

    await db.execute('''
      CREATE INDEX idx_user_entries_user_type_date ON user_entries (user_id, entry_type, created_at DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_emotion_analyses_user_id ON emotion_analyses (user_id, entry_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_dream_analyses_user_id ON dream_analyses (user_id, entry_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_chat_messages_user_timestamp ON chat_messages (user_id, timestamp DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_chat_messages_session ON chat_messages (session_id, timestamp)
    ''');

    await db.execute('''
      CREATE INDEX idx_user_preferences_user_key ON user_preferences (user_id, preference_key)
    ''');

    await db.execute('''
      CREATE INDEX idx_analysis_stats_user_date ON analysis_stats (user_id, date DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_user_sessions_user_token ON user_sessions (user_id, session_token)
    ''');
  }

  Future<void> saveUserPreference(String userId, String key, String value, String updatedAt) async {
  final db = await database;
  await db.insert(
    'user_preferences',
    {
      'user_id': userId,
      'preference_key': key,
      'preference_value': value,
      'updated_at': updatedAt,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<String?> getUserPreference(String userId, String key) async {
  final db = await database;
  final result = await db.query(
    'user_preferences',
    where: 'user_id = ? AND preference_key = ?',
    whereArgs: [userId, key],
    limit: 1,
  );
  return result.isNotEmpty ? result.first['preference_value'] as String : null;
}



  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      
      await _backupExistingData(db);
      
      await _addUserTables(db);
      
      await _migrateExistingDataToUser(db);
      
      debugPrint('Veritabanı güncelleme tamamlandı');
    }
    
    if (oldVersion < 3) {
      
      // Add analysis_type column to dream_analyses table
      await _addColumnIfNotExists(db, 'dream_analyses', 'analysis_type', 'TEXT DEFAULT "dream"');
      
      // Add model_used column to dream_analyses table
      await _addColumnIfNotExists(db, 'dream_analyses', 'model_used', 'TEXT DEFAULT ${ApiConstants.defaultModel}');
      
      // Update existing records to have analysis_type = 'dream'
      await db.execute('UPDATE dream_analyses SET analysis_type = "dream" WHERE analysis_type IS NULL');
      
      // Update existing records to have a default model_used value
      await db.execute('UPDATE dream_analyses SET model_used = ${ApiConstants.defaultModel} WHERE model_used IS NULL');
      
      debugPrint('✅ dream_analyses tablosuna analysis_type ve model_used sütunları eklendi');
    }

    if (oldVersion < 4) {
      await _migrateToFirebaseUID(db);
      debugPrint('✅ Firebase UID migration tamamlandı');
    }
  }

  Future<void> _migrateToFirebaseUID(Database db) async {
    // Geçici tablolar oluştur
    await db.execute('''
      CREATE TABLE users_new (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        display_name TEXT NOT NULL,
        avatar_url TEXT,
        created_at TEXT NOT NULL,
        last_login_at TEXT,
        is_active INTEGER DEFAULT 1 CHECK (is_active IN (0, 1)),
        user_preferences_json TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user_entries_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        content TEXT NOT NULL,
        entry_type TEXT NOT NULL CHECK (entry_type IN (
          'emotion', 'dream', 'personality', 'habit', 'mental', 'stress'
        )),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        model_used TEXT,
        is_analyzed INTEGER DEFAULT 0 CHECK (is_analyzed IN (0, 1))
      )
    ''');

    await db.execute('''
      CREATE TABLE emotion_analyses_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        entry_id INTEGER NOT NULL,
        analysis_type TEXT NOT NULL CHECK (analysis_type IN (
          'emotion', 'personality', 'habit', 'mental', 'stress'
        )),
        emotions_json TEXT NOT NULL,
        emotion_reasoning_json TEXT,
        themes_json TEXT NOT NULL,
        summary TEXT NOT NULL,
        advice TEXT NOT NULL,
        ai_reply TEXT,
        mind_map_json TEXT NOT NULL,
        model_used TEXT NOT NULL,
        analysis_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE dream_analyses_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        entry_id INTEGER NOT NULL,
        analysis_type TEXT NOT NULL DEFAULT 'dream',
        symbols_json TEXT NOT NULL,
        symbol_meanings_json TEXT NOT NULL,
        emotion_scores_json TEXT NOT NULL,
        themes_json TEXT NOT NULL,
        subconscious_message TEXT NOT NULL,
        summary TEXT NOT NULL,
        advice TEXT NOT NULL,
        ai_reply TEXT NOT NULL,
        mind_map_json TEXT NOT NULL,
        model_used TEXT NOT NULL,
        analysis_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_messages_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        message TEXT NOT NULL,
        message_type TEXT NOT NULL CHECK (message_type IN ('user', 'ai')),
        timestamp TEXT NOT NULL,
        model_used TEXT,
        analysis_data_json TEXT,
        session_id TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_preferences_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        preference_key TEXT NOT NULL,
        preference_value TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id, preference_key)
      )
    ''');

    await db.execute('''
      CREATE TABLE analysis_stats_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        analysis_type TEXT NOT NULL,
        model_used TEXT NOT NULL,
        success_count INTEGER DEFAULT 0,
        error_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        UNIQUE(user_id, date, analysis_type, model_used)
      )
    ''');

    // Demo kullanıcısı için Firebase UID oluştur
    const demoUID = 'demo_user_firebase_uid';
    
    // Verileri yeni tablolara kopyala
    await db.execute('''
      INSERT INTO users_new (id, email, display_name, avatar_url, created_at, last_login_at, is_active, user_preferences_json)
      SELECT ?, email, display_name, avatar_url, created_at, last_login_at, is_active, user_preferences_json
      FROM users WHERE id = 1
    ''', [demoUID]);

    await db.execute('''
      INSERT INTO user_entries_new (user_id, content, entry_type, created_at, updated_at, model_used, is_analyzed)
      SELECT ?, content, entry_type, created_at, updated_at, model_used, is_analyzed
      FROM user_entries WHERE user_id = 1
    ''', [demoUID]);

    await db.execute('''
      INSERT INTO emotion_analyses_new (user_id, entry_id, analysis_type, emotions_json, emotion_reasoning_json, themes_json, summary, advice, ai_reply, mind_map_json, model_used, analysis_date, created_at)
      SELECT ?, entry_id, analysis_type, emotions_json, emotion_reasoning_json, themes_json, summary, advice, ai_reply, mind_map_json, model_used, analysis_date, created_at
      FROM emotion_analyses WHERE user_id = 1
    ''', [demoUID]);

    await db.execute('''
      INSERT INTO dream_analyses_new (user_id, entry_id, analysis_type, symbols_json, symbol_meanings_json, emotion_scores_json, themes_json, subconscious_message, summary, advice, ai_reply, mind_map_json, model_used, analysis_date, created_at)
      SELECT ?, entry_id, analysis_type, symbols_json, symbol_meanings_json, emotion_scores_json, themes_json, subconscious_message, summary, advice, ai_reply, mind_map_json, model_used, analysis_date, created_at
      FROM dream_analyses WHERE user_id = 1
    ''', [demoUID]);

    await db.execute('''
      INSERT INTO chat_messages_new (user_id, message, message_type, timestamp, model_used, analysis_data_json, session_id, created_at)
      SELECT ?, message, message_type, timestamp, model_used, analysis_data_json, session_id, created_at
      FROM chat_messages WHERE user_id = 1
    ''', [demoUID]);

    await db.execute('''
      INSERT INTO user_preferences_new (user_id, preference_key, preference_value, updated_at)
      SELECT ?, preference_key, preference_value, updated_at
      FROM user_preferences WHERE user_id = 1
    ''', [demoUID]);

    await db.execute('''
      INSERT INTO analysis_stats_new (user_id, date, analysis_type, model_used, success_count, error_count, created_at)
      SELECT ?, date, analysis_type, model_used, success_count, error_count, created_at
      FROM analysis_stats WHERE user_id = 1
    ''', [demoUID]);

    // Eski tabloları sil
    await db.execute('DROP TABLE IF EXISTS users');
    await db.execute('DROP TABLE IF EXISTS user_entries');
    await db.execute('DROP TABLE IF EXISTS emotion_analyses');
    await db.execute('DROP TABLE IF EXISTS dream_analyses');
    await db.execute('DROP TABLE IF EXISTS chat_messages');
    await db.execute('DROP TABLE IF EXISTS user_preferences');
    await db.execute('DROP TABLE IF EXISTS analysis_stats');
    await db.execute('DROP TABLE IF EXISTS user_sessions');

    // Yeni tabloları yeniden adlandır
    await db.execute('ALTER TABLE users_new RENAME TO users');
    await db.execute('ALTER TABLE user_entries_new RENAME TO user_entries');
    await db.execute('ALTER TABLE emotion_analyses_new RENAME TO emotion_analyses');
    await db.execute('ALTER TABLE dream_analyses_new RENAME TO dream_analyses');
    await db.execute('ALTER TABLE chat_messages_new RENAME TO chat_messages');
    await db.execute('ALTER TABLE user_preferences_new RENAME TO user_preferences');
    await db.execute('ALTER TABLE analysis_stats_new RENAME TO analysis_stats');

    // Index'leri yeniden oluştur
    await db.execute('CREATE INDEX idx_users_email ON users (email)');
    await db.execute('CREATE INDEX idx_user_entries_user_type_date ON user_entries (user_id, entry_type, created_at DESC)');
    await db.execute('CREATE INDEX idx_emotion_analyses_user_id ON emotion_analyses (user_id, entry_id)');
    await db.execute('CREATE INDEX idx_dream_analyses_user_id ON dream_analyses (user_id, entry_id)');
    await db.execute('CREATE INDEX idx_chat_messages_user_timestamp ON chat_messages (user_id, timestamp DESC)');
    await db.execute('CREATE INDEX idx_chat_messages_session ON chat_messages (session_id, timestamp)');
    await db.execute('CREATE INDEX idx_user_preferences_user_key ON user_preferences (user_id, preference_key)');
    await db.execute('CREATE INDEX idx_analysis_stats_user_date ON analysis_stats (user_id, date DESC)');
  }

  Future<void> _addUserTables(Database db) async {
    final userTableExists = await _tableExists(db, 'users');
    if (!userTableExists) {
      debugPrint('Users tablosu oluşturuluyor...');
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE NOT NULL,
          email TEXT UNIQUE NOT NULL,
          password_hash TEXT NOT NULL,
          display_name TEXT NOT NULL,
          avatar_url TEXT,
          created_at TEXT NOT NULL,
          last_login_at TEXT,
          is_active INTEGER DEFAULT 1 CHECK (is_active IN (0, 1)),
          user_preferences_json TEXT
        )
      ''');
    }

    final sessionsTableExists = await _tableExists(db, 'user_sessions');
    if (!sessionsTableExists) {
      debugPrint('User sessions tablosu oluşturuluyor...');
      await db.execute('''
        CREATE TABLE user_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          session_token TEXT UNIQUE NOT NULL,
          device_info TEXT,
          ip_address TEXT,
          created_at TEXT NOT NULL,
          expires_at TEXT NOT NULL,
          is_active INTEGER DEFAULT 1 CHECK (is_active IN (0, 1)),
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
    }

    await _addColumnIfNotExists(db, 'user_entries', 'user_id', 'INTEGER DEFAULT 1');
    await _addColumnIfNotExists(db, 'emotion_analyses', 'user_id', 'INTEGER DEFAULT 1');
    await _addColumnIfNotExists(db, 'dream_analyses', 'user_id', 'INTEGER DEFAULT 1');
    await _addColumnIfNotExists(db, 'chat_messages', 'user_id', 'INTEGER DEFAULT 1');
    await _addColumnIfNotExists(db, 'user_preferences', 'user_id', 'INTEGER DEFAULT 1');
    await _addColumnIfNotExists(db, 'analysis_stats', 'user_id', 'INTEGER DEFAULT 1');
  }

  Future<bool> _tableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'",
    );
    return result.isNotEmpty;
  }

  Future<void> _addColumnIfNotExists(
    Database db, 
    String tableName, 
    String columnName, 
    String columnDefinition,
  ) async {
    try {
      final tableInfo = await db.rawQuery('PRAGMA table_info($tableName)');
      final columnExists = tableInfo.any((column) => column['name'] == columnName);
      
      if (!columnExists) {
        await db.execute('ALTER TABLE $tableName ADD COLUMN $columnName $columnDefinition');
      } else {
        debugPrint('✅ $tableName.$columnName sütunu zaten mevcut');
      }
    } catch (e) {
      debugPrint('⚠️ $tableName.$columnName sütunu eklenirken hata: $e');
    }
  }

  Future<void> _backupExistingData(Database db) async {
    debugPrint('📦 Mevcut veriler yedekleniyor...');
  }

  Future<void> _migrateExistingDataToUser(Database db) async {
    await _insertDefaultUser(db);
    
    await db.execute('UPDATE user_entries SET user_id = 1 WHERE user_id IS NULL');
    await db.execute('UPDATE emotion_analyses SET user_id = 1 WHERE user_id IS NULL');
    await db.execute('UPDATE dream_analyses SET user_id = 1 WHERE user_id IS NULL');
    await db.execute('UPDATE chat_messages SET user_id = 1 WHERE user_id IS NULL');
    await db.execute('UPDATE user_preferences SET user_id = 1 WHERE user_id IS NULL');
    await db.execute('UPDATE analysis_stats SET user_id = 1 WHERE user_id IS NULL');
    
    debugPrint('✅ Veriler demo kullanıcısına aktarıldı');
  }

  Future<void> _insertDefaultUser(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    await db.insert(
      'users',
      {
        'id': 1,
        'username': 'demo_user',
        'email': 'demo@mindflow.app',
        'password_hash': 'demo_hash',
        'display_name': 'Demo Kullanıcı',
        'created_at': now,
        'last_login_at': now,
        'is_active': 1,
        'user_preferences_json': jsonEncode({
          'selected_model': ApiConstants.defaultModel,
          'theme_mode': 'dark',
          'auto_save_enabled': true,
        }),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    final defaultPrefs = [
      {'user_id': 1, 'preference_key': 'selected_model', 'preference_value': ApiConstants.defaultModel},
      {'user_id': 1, 'preference_key': 'theme_mode', 'preference_value': 'dark'},
      {'user_id': 1, 'preference_key': 'auto_save_enabled', 'preference_value': 'true'},
      {'user_id': 1, 'preference_key': 'analysis_history_limit', 'preference_value': '50'},
    ];

    for (final pref in defaultPrefs) {
      await db.insert(
        'user_preferences',
        {
          ...pref,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  String _encodeJson(dynamic data) => jsonEncode(data);
  T _decodeJson<T>(String jsonString) => jsonDecode(jsonString) as T;

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mind_flow.db');
    await deleteDatabase(path);
    _database = null;
  }

  Future<Map<String, int>> getDatabaseInfo() async {
    final db = await database;
    
    final tables = ['users', 'user_entries', 'emotion_analyses', 'dream_analyses', 'chat_messages', 'languages'];
    final info = <String, int>{};
    
    for (final table in tables) {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
      info[table] = result.first['count'] as int;
    }
    
    return info;
  }
} 