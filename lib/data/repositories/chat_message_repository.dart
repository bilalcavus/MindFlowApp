import 'dart:convert';

import 'package:mind_flow/core/services/database_service.dart';
import 'package:mind_flow/data/models/chat_message.dart';

class ChatMessageRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<int> insertChatMessage({
    required String userId,
    required String message,
    required String messageType,
    String? modelUsed,
    Map<String, dynamic>? analysisData,
    String? sessionId,
  }) async {
    final db = await _dbService.database;
    final now = DateTime.now();

    return await db.insert(
      'chat_messages',
      {
        'user_id': userId,
        'message': message,
        'message_type': messageType,
        'timestamp': now.toIso8601String(),
        'model_used': modelUsed,
        'analysis_data_json': analysisData != null ? jsonEncode(analysisData) : null,
        'session_id': sessionId ?? _generateSessionId(now),
        'created_at': now.toIso8601String(),
      },
    );
  }

  Future<int> insertChatMessageFromModel({
    required ChatMessage chatMessage,
    String? userId,
    String? sessionId,
  }) async {
    final messageUserId = userId ?? chatMessage.userId;
    if (messageUserId == null) {
      throw ArgumentError('userId is required but not provided');
    }
    
    return await insertChatMessage(
      userId: messageUserId,
      message: chatMessage.message,
      messageType: chatMessage.type.name,
      modelUsed: chatMessage.modelUsed,
      analysisData: chatMessage.analysisData,
      sessionId: sessionId,
    );
  }

  Future<List<ChatMessage>> getChatMessagesBySession(String sessionId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'chat_messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );

    return results.map((row) => _mapToChatMessage(row)).toList();
  }

  Future<List<ChatMessage>> getChatMessagesBySessionAndUser(String sessionId, String userId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'chat_messages',
      where: 'session_id = ? AND user_id = ?',
      whereArgs: [sessionId, userId],
      orderBy: 'timestamp ASC',
    );

    return results.map((row) => _mapToChatMessage(row)).toList();
  }

  Future<List<Map<String, dynamic>>> getAllSessions({int? limit}) async {
    final db = await _dbService.database;
    final results = await db.rawQuery('''
      SELECT 
        session_id,
        user_id,
        MIN(timestamp) as first_message_time,
        MAX(timestamp) as last_message_time,
        COUNT(*) as message_count,
        COUNT(CASE WHEN message_type = 'user' THEN 1 END) as user_message_count,
        COUNT(CASE WHEN message_type = 'ai' THEN 1 END) as ai_message_count
      FROM chat_messages
      GROUP BY session_id, user_id
      ORDER BY last_message_time DESC
      ${limit != null ? 'LIMIT $limit' : ''}
    ''');

    return results;
  }

  Future<List<Map<String, dynamic>>> getSessionsForUser(String userId, {int? limit}) async {
    final db = await _dbService.database;
    final results = await db.rawQuery('''
      SELECT 
        session_id,
        user_id,
        MIN(timestamp) as first_message_time,
        MAX(timestamp) as last_message_time,
        COUNT(*) as message_count,
        COUNT(CASE WHEN message_type = 'user' THEN 1 END) as user_message_count,
        COUNT(CASE WHEN message_type = 'ai' THEN 1 END) as ai_message_count
      FROM chat_messages
      WHERE user_id = ?
      GROUP BY session_id
      ORDER BY last_message_time DESC
      ${limit != null ? 'LIMIT $limit' : ''}
    ''', [userId]);

    return results;
  }

  Future<List<ChatMessage>> getRecentMessages({int limit = 50}) async {
    final db = await _dbService.database;
    final results = await db.query(
      'chat_messages',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return results.reversed.map((row) => _mapToChatMessage(row)).toList();
  }

  Future<List<ChatMessage>> getRecentMessagesForUser(String userId, {int limit = 50}) async {
    final db = await _dbService.database;
    final results = await db.query(
      'chat_messages',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return results.reversed.map((row) => _mapToChatMessage(row)).toList();
  }

  Future<List<ChatMessage>> getChatMessagesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? sessionId,
  }) async {
    final db = await _dbService.database;
    
    String whereClause = 'timestamp >= ? AND timestamp <= ?';
    List<dynamic> whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];

    if (sessionId != null) {
      whereClause += ' AND session_id = ?';
      whereArgs.add(sessionId);
    }

    final results = await db.query(
      'chat_messages',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp ASC',
    );

    return results.map((row) => _mapToChatMessage(row)).toList();
  }

  Future<List<ChatMessage>> getChatMessagesByModel(String modelUsed) async {
    final db = await _dbService.database;
    final results = await db.query(
      'chat_messages',
      where: 'model_used = ?',
      whereArgs: [modelUsed],
      orderBy: 'timestamp DESC',
    );

    return results.map((row) => _mapToChatMessage(row)).toList();
  }

  Future<List<ChatMessage>> searchChatMessages(String searchTerm) async {
    final db = await _dbService.database;
    final results = await db.query(
      'chat_messages',
      where: 'message LIKE ?',
      whereArgs: ['%$searchTerm%'],
      orderBy: 'timestamp DESC',
    );

    return results.map((row) => _mapToChatMessage(row)).toList();
  }

  Future<int> deleteChatSession(String sessionId) async {
    final db = await _dbService.database;
    return await db.delete(
      'chat_messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<int> deleteChatMessage(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      'chat_messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteOldMessages(DateTime cutoffDate) async {
    final db = await _dbService.database;
    return await db.delete(
      'chat_messages',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  Future<Map<String, dynamic>> getChatStats() async {
    final db = await _dbService.database;
    
    final totalResult = await db.rawQuery('SELECT COUNT(*) as total FROM chat_messages');
    final total = totalResult.first['total'] as int;

    final typeResults = await db.rawQuery('''
      SELECT message_type, COUNT(*) as count
      FROM chat_messages
      GROUP BY message_type
    ''');

    final typeStats = <String, int>{};
    for (final row in typeResults) {
      typeStats[row['message_type'] as String] = row['count'] as int;
    }

    final modelResults = await db.rawQuery('''
      SELECT model_used, COUNT(*) as count
      FROM chat_messages
      WHERE message_type = 'ai' AND model_used IS NOT NULL
      GROUP BY model_used
    ''');

    final modelStats = <String, int>{};
    for (final row in modelResults) {
      modelStats[row['model_used'] as String] = row['count'] as int;
    }

    final sessionResult = await db.rawQuery('SELECT COUNT(DISTINCT session_id) as session_count FROM chat_messages');
    final sessionCount = sessionResult.first['session_count'] as int;

    final dailyResults = await db.rawQuery('''
      SELECT 
        DATE(timestamp) as date,
        COUNT(*) as count
      FROM chat_messages
      WHERE timestamp >= datetime('now', '-30 days')
      GROUP BY DATE(timestamp)
      ORDER BY date DESC
    ''');

    final dailyStats = <String, int>{};
    for (final row in dailyResults) {
      dailyStats[row['date'] as String] = row['count'] as int;
    }

    return {
      'total_messages': total,
      'by_type': typeStats,
      'by_model': modelStats,
      'session_count': sessionCount,
      'daily_last_30_days': dailyStats,
    };
  }

  String _generateSessionId(DateTime timestamp) {
    return 'session_${timestamp.millisecondsSinceEpoch}';
  }

  ChatMessage _mapToChatMessage(Map<String, dynamic> row) {
    return ChatMessage(
      userId: row['user_id'],
      message: row['message'],
      type: MessageType.values.firstWhere((e) => e.name == row['message_type']),
      timestamp: DateTime.parse(row['timestamp']),
      modelUsed: row['model_used'],
      analysisData: row['analysis_data_json'] != null 
          ? jsonDecode(row['analysis_data_json']) 
          : null,
    );
  }

  Future<String?> getLastActiveSessionId() async {
    final db = await _dbService.database;
    final results = await db.query(
      'chat_messages',
      columns: ['session_id'],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    return results.isNotEmpty ? results.first['session_id'] as String : null;
  }

  Future<String> startNewSession() async {
    final now = DateTime.now();
    return _generateSessionId(now);
  }
} 