import 'package:mind_flow/core/services/database_service.dart';

class UserEntryRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<int> insertUserEntry({
    required String userId,
    required String content,
    required String entryType,
    String? modelUsed,
  }) async {
    final db = await _dbService.database;
    final now = DateTime.now().toIso8601String();

    return await db.insert(
      'user_entries',
      {
        'user_id': userId,
        'content': content,
        'entry_type': entryType,
        'created_at': now,
        'updated_at': now,
        'model_used': modelUsed,
        'is_analyzed': 0,
      },
    );
  }

  Future<int> updateUserEntry({
    required String userId,
    required int id,
    String? content,
    String? entryType,
    String? modelUsed,
    bool? isAnalyzed,
  }) async {
    final db = await _dbService.database;
    final now = DateTime.now().toIso8601String();

    final data = <String, dynamic>{
      'updated_at': now,
    };

    if (content != null) data['content'] = content;
    if (entryType != null) data['entry_type'] = entryType;
    if (modelUsed != null) data['model_used'] = modelUsed;
    if (isAnalyzed != null) data['is_analyzed'] = isAnalyzed ? 1 : 0;

    return await db.update(
      'user_entries',
      data,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<Map<String, dynamic>?> getUserEntryById(String userId, int id) async {
    final db = await _dbService.database;
    final result = await db.query(
      'user_entries',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
      limit: 1,
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getUserEntriesByType({
    required String userId,
    required String entryType,
    int? limit,
    int? offset,
  }) async {
    final db = await _dbService.database;
    final result = await db.query(
      'user_entries',
      where: 'user_id = ? AND entry_type = ?',
      whereArgs: [userId, entryType],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getUnanalyzedEntries(String userId) async {
    final db = await _dbService.database;
    final result = await db.query(
      'user_entries',
      where: 'user_id = ? AND is_analyzed = 0',
      whereArgs: [userId],
      orderBy: 'created_at ASC',
    );

    return result;
  }

  Future<int> deleteUserEntry(String userId, int id) async {
    final db = await _dbService.database;
    return await db.delete(
      'user_entries',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<Map<String, int>> getEntryStatsByType(String userId) async {
    final db = await _dbService.database;
    final result = await db.rawQuery('''
      SELECT 
        entry_type,
        COUNT(*) as count
      FROM user_entries 
      WHERE user_id = ?
      GROUP BY entry_type
    ''', [userId]);

    final stats = <String, int>{};
    for (final row in result) {
      stats[row['entry_type'] as String] = row['count'] as int;
    }

    return stats;
  }

  Future<List<Map<String, dynamic>>> getUserEntriesByDateRange({
    required String userId,
    required String entryType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _dbService.database;
    final result = await db.query(
      'user_entries',
      where: 'user_id = ? AND entry_type = ? AND created_at BETWEEN ? AND ?',
      whereArgs: [
        userId,
        entryType,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'created_at DESC',
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getAllUserEntries({
    required String userId,
    int? limit,
    int? offset,
  }) async {
    final db = await _dbService.database;
    final result = await db.query(
      'user_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );

    return result;
  }

  Future<int> getUserEntryCount(String userId) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM user_entries WHERE user_id = ?',
      [userId],
    );

    return result.first['count'] as int;
  }
} 