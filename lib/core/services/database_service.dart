import 'dart:convert';

import 'package:flutter/material.dart';
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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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

    await db.execute('''
      CREATE TABLE user_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
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
        user_id INTEGER NOT NULL,
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
        user_id INTEGER NOT NULL,
        entry_id INTEGER NOT NULL,
        symbols_json TEXT NOT NULL,
        symbol_meanings_json TEXT NOT NULL,
        emotion_scores_json TEXT NOT NULL,
        themes_json TEXT NOT NULL,
        subconscious_message TEXT NOT NULL,
        summary TEXT NOT NULL,
        advice TEXT NOT NULL,
        ai_reply TEXT NOT NULL,
        mind_map_json TEXT NOT NULL,
        analysis_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (entry_id) REFERENCES user_entries (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
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
        user_id INTEGER NOT NULL,
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
        user_id INTEGER NOT NULL,
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

    await db.execute('''
      CREATE INDEX idx_users_email ON users (email)
    ''');

    await db.execute('''
      CREATE INDEX idx_users_username ON users (username)
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
      CREATE INDEX idx_user_sessions_token ON user_sessions (session_token)
    ''');

    await db.execute('''
      CREATE INDEX idx_user_sessions_expires ON user_sessions (expires_at)
    ''');

    await _insertDefaultUser(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      print('🔄 Veritabanı güncelleniyor: v$oldVersion -> v$newVersion');
      
      await _backupExistingData(db);
      
      await _addUserTables(db);
      
      await _migrateExistingDataToUser(db);
      
      debugPrint('Veritabanı güncelleme tamamlandı');
    }
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
        print('📝 $tableName tablosuna $columnName sütunu ekleniyor...');
        await db.execute('ALTER TABLE $tableName ADD COLUMN $columnName $columnDefinition');
      } else {
        print('✅ $tableName.$columnName sütunu zaten mevcut');
      }
    } catch (e) {
      print('⚠️ $tableName.$columnName sütunu eklenirken hata: $e');
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
        'password_hash': 'demo_hash', // Demo için basit hash
        'display_name': 'Demo Kullanıcı',
        'created_at': now,
        'last_login_at': now,
        'is_active': 1,
        'user_preferences_json': jsonEncode({
          'selected_model': 'mistral-small-3.2',
          'theme_mode': 'dark',
          'auto_save_enabled': true,
        }),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    final defaultPrefs = [
      {'user_id': 1, 'preference_key': 'selected_model', 'preference_value': 'mistral-small-3.2'},
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
    
    final tables = ['users', 'user_entries', 'emotion_analyses', 'dream_analyses', 'chat_messages'];
    final info = <String, int>{};
    
    for (final table in tables) {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
      info[table] = result.first['count'] as int;
    }
    
    return info;
  }
} 