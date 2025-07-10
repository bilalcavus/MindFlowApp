import 'dart:convert';

import 'package:mind_flow/core/services/database_service.dart';
import 'package:mind_flow/data/models/emotion_analysis_model.dart';

class EmotionAnalysisRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<int> insertEmotionAnalysis({
    required String userId,
    required int entryId,
    required String analysisType,
    required EmotionAnalysisModel analysis,
    String? modelUsed,
  }) async {
    final db = await _dbService.database;

    return await db.insert(
      'emotion_analyses',
      {
        'user_id': userId,
        'entry_id': entryId,
        'analysis_type': analysisType,
        'emotions_json': jsonEncode(analysis.emotions),
        'emotion_reasoning_json': null,
        'themes_json': jsonEncode(analysis.themes),
        'summary': analysis.summary,
        'advice': analysis.advice,
        'ai_reply': null,
        'mind_map_json': jsonEncode(analysis.mindMap),
        'model_used': analysis.modelUsed,
        'analysis_date': analysis.analysisDate.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<int> updateEmotionAnalysis({
    required String userId,
    required int id,
    EmotionAnalysisModel? analysis,
  }) async {
    final db = await _dbService.database;
    if (analysis == null) return 0;

    return await db.update(
      'emotion_analyses',
      {
        'emotions_json': jsonEncode(analysis.emotions),
        'themes_json': jsonEncode(analysis.themes),
        'summary': analysis.summary,
        'advice': analysis.advice,
        'mind_map_json': jsonEncode(analysis.mindMap),
        'model_used': analysis.modelUsed,
        'analysis_date': analysis.analysisDate.toIso8601String(),
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<EmotionAnalysisModel?> getEmotionAnalysisById(int id) async {
    final db = await _dbService.database;    
    final results = await db.query(
      'emotion_analyses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) {
      return null;
    }
    return _mapToEmotionAnalysisModel(results.first);
  }

  Future<EmotionAnalysisModel?> getEmotionAnalysisByEntryId(String userId, int entryId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'emotion_analyses',
      where: 'entry_id = ? AND user_id = ?',
      whereArgs: [entryId, userId],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (results.isEmpty) return null;

    return _mapToEmotionAnalysisModel(results.first);
  }

  Future<List<EmotionAnalysisModel>> getEmotionAnalysesByType({
    required String userId,
    required String analysisType,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _dbService.database;
    
    String whereClause = 'user_id = ? AND analysis_type = ?';
    List<dynamic> whereArgs = [userId, analysisType];

    if (startDate != null) {
      whereClause += ' AND analysis_date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClause += ' AND analysis_date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final results = await db.query(
      'emotion_analyses',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'analysis_date DESC',
      limit: limit,
    );

    return results.map((row) => _mapToEmotionAnalysisModel(row)).toList();
  }

  Future<List<EmotionAnalysisModel>> getAllEmotionAnalyses({
    required String userId,
    int? limit,
    String? analysisType,
  }) async {
    final db = await _dbService.database;
    
    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (analysisType != null) {
      whereClause += ' AND analysis_type = ?';
      whereArgs.add(analysisType);
    }

    final results = await db.query(
      'emotion_analyses',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'analysis_date DESC',
      limit: limit,
    );

    return results.map((row) => _mapToEmotionAnalysisModel(row)).toList();
  }

  Future<List<Map<String, dynamic>>> getAnalysesWithEntries({
    required String userId,
    String? analysisType,
    int? limit,
  }) async {
    final db = await _dbService.database;
    
    String whereClause = 'WHERE ea.user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (analysisType != null) {
      whereClause += ' AND ea.analysis_type = ?';
      whereArgs.add(analysisType);
    }

    final results = await db.rawQuery('''
      SELECT 
        ea.*,
        ue.content as original_content,
        ue.created_at as entry_created_at
      FROM emotion_analyses ea
      INNER JOIN user_entries ue ON ea.entry_id = ue.id
      $whereClause
      ORDER BY ea.analysis_date DESC
      ${limit != null ? 'LIMIT $limit' : ''}
    ''', whereArgs);

    return results;
  }

  Future<int> deleteEmotionAnalysis(String userId, int id) async {
    final db = await _dbService.database;
    return await db.delete(
      'emotion_analyses',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<int> deleteEmotionAnalysesByEntryId(String userId, int entryId) async {
    final db = await _dbService.database;
    return await db.delete(
      'emotion_analyses',
      where: 'entry_id = ? AND user_id = ?',
      whereArgs: [entryId, userId],
    );
  }

  Future<int> deleteAllUserAnalyses(String userId) async {
    final db = await _dbService.database;
    return await db.delete(
      'emotion_analyses',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<Map<String, dynamic>> getEmotionAnalysisStats(String userId) async {
    final db = await _dbService.database;
    
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM emotion_analyses WHERE user_id = ?',
      [userId],
    );
    final total = totalResult.first['total'] as int;

    final typeResults = await db.rawQuery('''
      SELECT analysis_type, COUNT(*) as count
      FROM emotion_analyses
      WHERE user_id = ?
      GROUP BY analysis_type
    ''', [userId]);

    final typeStats = <String, int>{};
    for (final row in typeResults) {
      typeStats[row['analysis_type'] as String] = row['count'] as int;
    }

    final modelResults = await db.rawQuery('''
      SELECT model_used, COUNT(*) as count
      FROM emotion_analyses
      WHERE user_id = ?
      GROUP BY model_used
    ''', [userId]);

    final modelStats = <String, int>{};
    for (final row in modelResults) {
      modelStats[row['model_used'] as String] = row['count'] as int;
    }

    return {
      'total': total,
      'by_type': typeStats,
      'by_model': modelStats,
    };
  }

  EmotionAnalysisModel _mapToEmotionAnalysisModel(Map<String, dynamic> row) {
    final id = row['id'] as int?;
    
    return EmotionAnalysisModel(
      id: id,
      emotions: Map<String, int>.from(jsonDecode(row['emotions_json'])),
      themes: List<String>.from(jsonDecode(row['themes_json'])),
      advice: row['advice'],
      mindMap: Map<String, List<String>>.from(
        (jsonDecode(row['mind_map_json']) as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      summary: row['summary'],
      modelUsed: row['model_used'],
      analysisDate: DateTime.parse(row['analysis_date']),
    );
  }
} 