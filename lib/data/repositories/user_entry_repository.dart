import 'package:mind_flow/core/services/database_service.dart';

class UserEntryRepository {
  final DatabaseService _dbService = DatabaseService();

  // Kullanıcı girdisi kaydetme
  Future<int> insertUserEntry({
    required int userId,
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

  // Kullanıcı girdisini güncelleme
  Future<int> updateUserEntry({
    required int userId,
    required int id,
    String? content,
    String? modelUsed,
    bool? isAnalyzed,
  }) async {
    final db = await _dbService.database;
    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (content != null) updateData['content'] = content;
    if (modelUsed != null) updateData['model_used'] = modelUsed;
    if (isAnalyzed != null) updateData['is_analyzed'] = isAnalyzed ? 1 : 0;

    return await db.update(
      'user_entries',
      updateData,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // ID ile kullanıcı girdisi getirme
  Future<Map<String, dynamic>?> getUserEntryById(int userId, int id) async {
    final db = await _dbService.database;
    final results = await db.query(
      'user_entries',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );

    return results.isNotEmpty ? results.first : null;
  }

  // Tip ve tarih aralığına göre girdi listeleme
  Future<List<Map<String, dynamic>>> getUserEntriesByType({
    required int userId,
    required String entryType,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final db = await _dbService.database;
    String whereClause = 'user_id = ? AND entry_type = ?';
    List<dynamic> whereArgs = [userId, entryType];

    if (startDate != null) {
      whereClause += ' AND created_at >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClause += ' AND created_at <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    return await db.query(
      'user_entries',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  // Tüm analiz edilmemiş girdileri getirme
  Future<List<Map<String, dynamic>>> getUnanalyzedEntries(int userId) async {
    final db = await _dbService.database;
    return await db.query(
      'user_entries',
      where: 'user_id = ? AND is_analyzed = ?',
      whereArgs: [userId, 0],
      orderBy: 'created_at DESC',
    );
  }

  // Son N girdiyi getirme
  Future<List<Map<String, dynamic>>> getRecentEntries({
    required int userId,
    int limit = 10,
  }) async {
    final db = await _dbService.database;
    return await db.query(
      'user_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  // Kullanıcı girdisini silme
  Future<int> deleteUserEntry(int userId, int id) async {
    final db = await _dbService.database;
    return await db.delete(
      'user_entries',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // Tip bazında istatistik getirme
  Future<Map<String, int>> getEntryStatsByType(int userId) async {
    final db = await _dbService.database;
    final results = await db.rawQuery('''
      SELECT entry_type, COUNT(*) as count
      FROM user_entries
      WHERE user_id = ?
      GROUP BY entry_type
    ''', [userId]);

    final stats = <String, int>{};
    for (final row in results) {
      stats[row['entry_type'] as String] = row['count'] as int;
    }

    return stats;
  }

  // Belirli tarih aralığındaki girdi sayısı
  Future<int> getEntryCountInDateRange({
    required int userId,
    required DateTime startDate,
    required DateTime endDate,
    String? entryType,
  }) async {
    final db = await _dbService.database;
    String whereClause = 'user_id = ? AND created_at >= ? AND created_at <= ?';
    List<dynamic> whereArgs = [userId, startDate.toIso8601String(), endDate.toIso8601String()];

    if (entryType != null) {
      whereClause += ' AND entry_type = ?';
      whereArgs.add(entryType);
    }

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM user_entries
      WHERE $whereClause
    ''', whereArgs);

    return result.first['count'] as int;
  }

  // Kullanıcının tüm girdilerini getirme
  Future<List<Map<String, dynamic>>> getAllUserEntries({
    required int userId,
    int? limit,
    int? offset,
  }) async {
    final db = await _dbService.database;
    return await db.query(
      'user_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
  }

  // Kullanıcının toplam girdi sayısı
  Future<int> getUserEntryCount(int userId) async {
    final db = await _dbService.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM user_entries
      WHERE user_id = ?
    ''', [userId]);

    return result.first['count'] as int;
  }
} 