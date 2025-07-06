import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:mind_flow/core/services/database_service.dart';
import 'package:mind_flow/data/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

class AuthRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<User> register({
    required String username,
    required String email,
    required String password,
    required String displayName,
    String? avatarUrl,
  }) async {
    final db = await _dbService.database;
    
    final existingUser = await _getUserByEmailOrUsername(email, username);
    if (existingUser != null) {
      throw Exception('Bu email veya kullanıcı adı zaten kullanılıyor');
    }

    final passwordHash = _hashPassword(password);
    final now = DateTime.now();

    final userId = await db.insert(
      'users',
      {
        'username': username,
        'email': email,
        'password_hash': passwordHash,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'created_at': now.toIso8601String(),
        'last_login_at': now.toIso8601String(),
        'is_active': 1,
        'user_preferences_json': jsonEncode({
          'selected_model': 'mistral-small-3.2',
          'theme_mode': 'dark',
          'auto_save_enabled': true,
        }),
      },
    );

    await _createDefaultPreferences(userId);

    final user = await getUserById(userId);
    if (user == null) {
      throw Exception('Kullanıcı oluşturulamadı');
    }

    return user;
  }

  Future<UserSession> login({
    required String emailOrUsername,
    required String password,
    String? deviceInfo,
    String? ipAddress,
  }) async {
    final db = await _dbService.database;

    final user = await _getUserByEmailOrUsername(emailOrUsername, emailOrUsername);
    if (user == null) {
      throw Exception('Kullanıcı bulunamadı');
    }

    if (!_verifyPassword(password, await _getPasswordHash(user.id))) {
      throw Exception('Geçersiz şifre');
    }

    if (!user.isActive) {
      throw Exception('Hesap devre dışı bırakıldı');
    }

    await db.update(
      'users',
      {'last_login_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [user.id],
    );

    return await createSession(
      userId: user.id,
      deviceInfo: deviceInfo,
      ipAddress: ipAddress,
    );
  }

  Future<UserSession> createSession({
    required int userId,
    String? deviceInfo,
    String? ipAddress,
    Duration? duration,
  }) async {
    final db = await _dbService.database;
    final now = DateTime.now();
    final expiresAt = now.add(duration ?? const Duration(days: 30));
    final sessionToken = _generateSessionToken();

    final sessionId = await db.insert(
      'user_sessions',
      {
        'user_id': userId,
        'session_token': sessionToken,
        'device_info': deviceInfo,
        'ip_address': ipAddress,
        'created_at': now.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'is_active': 1,
      },
    );

    return UserSession(
      id: sessionId,
      userId: userId,
      sessionToken: sessionToken,
      deviceInfo: deviceInfo,
      ipAddress: ipAddress,
      createdAt: now,
      expiresAt: expiresAt,
      isActive: true,
    );
  }

  Future<User?> validateSession(String sessionToken) async {
    final db = await _dbService.database;

    final results = await db.rawQuery('''
      SELECT u.*, s.expires_at, s.is_active as session_active
      FROM users u
      INNER JOIN user_sessions s ON u.id = s.user_id
      WHERE s.session_token = ? AND s.is_active = 1
    ''', [sessionToken]);

    if (results.isEmpty) return null;

    final row = results.first;
    final expiresAt = DateTime.parse(row['expires_at'] as String);
    
    if (DateTime.now().isAfter(expiresAt)) {
      await clearSession(sessionToken);
      return null;
    }

    return User.fromJson(row);
  }

  Future<void> logout(String sessionToken) async {
    await clearSession(sessionToken);
  }

  // Oturum Geçersiz Kılma
  Future<void> clearSession(String sessionToken) async {
    final db = await _dbService.database;
    await db.update(
      'user_sessions',
      {'is_active': 0},
      where: 'session_token = ?',
      whereArgs: [sessionToken],
    );
  }

  Future<void> logoutAllSessions(int userId) async {
    final db = await _dbService.database;
    await db.update(
      'user_sessions',
      {'is_active': 0},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<User?> getUserById(int id) async {
    final db = await _dbService.database;
    final results = await db.query(
      'users',
      where: 'id = ? AND is_active = 1',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return User.fromJson(results.first);
  }

  Future<User?> _getUserByEmailOrUsername(String email, String username) async {
    final db = await _dbService.database;
    final results = await db.query(
      'users',
      where: '(email = ? OR username = ?) AND is_active = 1',
      whereArgs: [email, username],
    );

    if (results.isEmpty) return null;
    return User.fromJson(results.first);
  }

  Future<String> _getPasswordHash(int userId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'users',
      columns: ['password_hash'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    return results.first['password_hash'] as String;
  }

  Future<User> updateProfile({
    required int userId,
    String? displayName,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
  }) async {
    final db = await _dbService.database;
    final updateData = <String, dynamic>{};

    if (displayName != null) updateData['display_name'] = displayName;
    if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
    if (preferences != null) {
      updateData['user_preferences_json'] = jsonEncode(preferences);
    }

    if (updateData.isNotEmpty) {
      await db.update(
        'users',
        updateData,
        where: 'id = ?',
        whereArgs: [userId],
      );
    }

    final user = await getUserById(userId);
    if (user == null) throw Exception('Kullanıcı bulunamadı');
    return user;
  }

  Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final db = await _dbService.database;

    final currentHash = await _getPasswordHash(userId);
    if (!_verifyPassword(currentPassword, currentHash)) {
      throw Exception('Mevcut şifre yanlış');
    }

    final newHash = _hashPassword(newPassword);

    await db.update(
      'users',
      {'password_hash': newHash},
      where: 'id = ?',
      whereArgs: [userId],
    );

    await logoutAllSessions(userId);
  }

  Future<void> setUserActive(int userId, bool isActive) async {
    final db = await _dbService.database;
    await db.update(
      'users',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (!isActive) {
      await logoutAllSessions(userId);
    }
  }

  Future<List<UserSession>> getUserSessions(int userId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'user_sessions',
      where: 'user_id = ? AND is_active = 1',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return results.map((row) => UserSession.fromJson(row)).toList();
  }

  Future<void> cleanupExpiredSessions() async {
    final db = await _dbService.database;
    await db.update(
      'user_sessions',
      {'is_active': 0},
      where: 'expires_at < ?',
      whereArgs: [DateTime.now().toIso8601String()],
    );
  }

  Future<void> _createDefaultPreferences(int userId) async {
    final db = await _dbService.database;
    final now = DateTime.now().toIso8601String();

    final defaultPrefs = [
      {'user_id': userId, 'preference_key': 'selected_model', 'preference_value': 'mistral-small-3.2'},
      {'user_id': userId, 'preference_key': 'theme_mode', 'preference_value': 'dark'},
      {'user_id': userId, 'preference_key': 'auto_save_enabled', 'preference_value': 'true'},
      {'user_id': userId, 'preference_key': 'analysis_history_limit', 'preference_value': '50'},
      {'user_id': userId, 'preference_key': 'notifications_enabled', 'preference_value': 'true'},
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

  // Şifre Hash'leme
  String _hashPassword(String password) {
    final salt = 'mind_flow_salt_2024'; // Production'da dinamik salt kullan
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool _verifyPassword(String password, String hash) {
    return _hashPassword(password) == hash;
  }

  String _generateSessionToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
} 