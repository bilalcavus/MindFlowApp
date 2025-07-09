import 'dart:convert';

import 'package:mind_flow/core/services/database_service.dart';
import 'package:mind_flow/data/models/dream_analysis_model.dart';

class DreamAnalysisDataRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<int> insertDreamAnalysis({
    required String userId,
    required int entryId,
    required String analysisType,
    required DreamAnalysisModel analysis,
    String? modelUsed,
  }) async {
    final db = await _dbService.database;

    return await db.insert(
      'dream_analyses',
      {
        'entry_id': entryId,
        'user_id': userId,
        'analysis_type': analysisType,
        'symbols_json': jsonEncode(analysis.symbols),
        'symbol_meanings_json': jsonEncode(analysis.symbolMeanings),
        'emotion_scores_json': jsonEncode(analysis.emotionScores),
        'themes_json': jsonEncode(analysis.themes),
        'subconscious_message': analysis.subconsciousMessage,
        'summary': analysis.summary,
        'advice': analysis.advice,
        'ai_reply': analysis.aiReply,
        'mind_map_json': jsonEncode(analysis.mindMap),
        'model_used': modelUsed ?? 'mistral-small-3.2',
        'analysis_date': analysis.analysisDate.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<int> updateDreamAnalysis({
    required int id,
    required DreamAnalysisModel analysis,
  }) async {
    final db = await _dbService.database;

    return await db.update(
      'dream_analyses',
      {
        'symbols_json': jsonEncode(analysis.symbols),
        'symbol_meanings_json': jsonEncode(analysis.symbolMeanings),
        'emotion_scores_json': jsonEncode(analysis.emotionScores),
        'themes_json': jsonEncode(analysis.themes),
        'subconscious_message': analysis.subconsciousMessage,
        'summary': analysis.summary,
        'advice': analysis.advice,
        'ai_reply': analysis.aiReply,
        'mind_map_json': jsonEncode(analysis.mindMap),
        'model_used': analysis.modelUsed,
        'analysis_date': analysis.analysisDate.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<DreamAnalysisModel?> getDreamAnalysisById(int id) async {
    final db = await _dbService.database;
    print('🔍 Veritabanında analiz aranıyor: ID $id');
    
    final results = await db.query(
      'dream_analyses',
      where: 'id = ?',
      whereArgs: [id],
    );

    print('📊 Sorgu sonucu: ${results.length} kayıt bulundu');
    
    if (results.isEmpty) {
      print('❌ Analiz bulunamadı: ID $id');
      return null;
    }

    print('✅ Analiz bulundu: ID $id');
    return _mapToDreamAnalysisModel(results.first);
  }

  Future<DreamAnalysisModel?> getDreamAnalysisByEntryId(int entryId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'dream_analyses',
      where: 'entry_id = ?',
      whereArgs: [entryId],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (results.isEmpty) return null;

    return _mapToDreamAnalysisModel(results.first);
  }

  Future<List<DreamAnalysisModel>> getDreamAnalysesByType({
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
      'dream_analyses',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'analysis_date DESC',
      limit: limit,
    );

    return results.map((row) => _mapToDreamAnalysisModel(row)).toList();
  }

  Future<List<DreamAnalysisModel>> getAllDreamAnalyses({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _dbService.database;
    
    String? whereClause;
    List<dynamic>? whereArgs;

    if (startDate != null || endDate != null) {
      whereClause = '';
      whereArgs = [];

      if (startDate != null) {
        whereClause += 'analysis_date >= ?';
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'analysis_date <= ?';
        whereArgs.add(endDate.toIso8601String());
      }
    }

    final results = await db.query(
      'dream_analyses',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'analysis_date DESC',
      limit: limit,
    );

    return results.map((row) => _mapToDreamAnalysisModel(row)).toList();
  }

  Future<List<Map<String, dynamic>>> getDreamAnalysesWithEntries({
    int? limit,
  }) async {
    final db = await _dbService.database;

    final results = await db.rawQuery('''
      SELECT 
        da.*,
        ue.content as original_content,
        ue.created_at as entry_created_at
      FROM dream_analyses da
      INNER JOIN user_entries ue ON da.entry_id = ue.id
      ORDER BY da.analysis_date DESC
      ${limit != null ? 'LIMIT $limit' : ''}
    ''');

    return results;
  }

  Future<List<DreamAnalysisModel>> searchBySymbol(String symbol) async {
    final db = await _dbService.database;
    
    final results = await db.query(
      'dream_analyses',
      where: 'symbols_json LIKE ?',
      whereArgs: ['%"$symbol"%'],
      orderBy: 'analysis_date DESC',
    );

    return results.map((row) => _mapToDreamAnalysisModel(row)).toList();
  }

  Future<List<DreamAnalysisModel>> searchByTheme(String theme) async {
    final db = await _dbService.database;
    
    final results = await db.query(
      'dream_analyses',
      where: 'themes_json LIKE ?',
      whereArgs: ['%"$theme"%'],
      orderBy: 'analysis_date DESC',
    );

    return results.map((row) => _mapToDreamAnalysisModel(row)).toList();
  }

  Future<Map<String, int>> getMostCommonSymbols({int? limit}) async {
    final db = await _dbService.database;
    final results = await db.query('dream_analyses');
    
    final symbolCounts = <String, int>{};
    
    for (final row in results) {
      final symbols = List<String>.from(jsonDecode(row['symbols_json'] as String));
      for (final symbol in symbols) {
        symbolCounts[symbol] = (symbolCounts[symbol] ?? 0) + 1;
      }
    }

    final sortedEntries = symbolCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (limit != null) {
      return Map.fromEntries(sortedEntries.take(limit));
    }

    return Map.fromEntries(sortedEntries);
  }

  Future<Map<String, int>> getMostCommonThemes({int? limit}) async {
    final db = await _dbService.database;
    final results = await db.query('dream_analyses');
    
    final themeCounts = <String, int>{};
    
    for (final row in results) {
      final themes = List<String>.from(jsonDecode(row['themes_json'] as String));
      for (final theme in themes) {
        themeCounts[theme] = (themeCounts[theme] ?? 0) + 1;
      }
    }

    final sortedEntries = themeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (limit != null) {
      return Map.fromEntries(sortedEntries.take(limit));
    }

    return Map.fromEntries(sortedEntries);
  }

  Future<int> deleteDreamAnalysis(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      'dream_analyses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteDreamAnalysesByEntryId(int entryId) async {
    final db = await _dbService.database;
    return await db.delete(
      'dream_analyses',
      where: 'entry_id = ?',
      whereArgs: [entryId],
    );
  }

  Future<Map<String, dynamic>> getDreamAnalysisStats(String userId) async {
    final db = await _dbService.database;
    final totalResult = await db.rawQuery('SELECT COUNT(*) as total FROM dream_analyses WHERE user_id = ?', [userId]);
    
    final byTypeResult = await db.rawQuery('''
      SELECT analysis_type, COUNT(*) as count 
      FROM dream_analyses 
      WHERE user_id = ? 
      GROUP BY analysis_type
    ''', [userId]);

    final byModelResult = await db.rawQuery('''
      SELECT model_used, COUNT(*) as count 
      FROM dream_analyses 
      WHERE user_id = ? 
      GROUP BY model_used
    ''', [userId]);

    final byDateResult = await db.rawQuery('''
      SELECT DATE(analysis_date) as date, COUNT(*) as count 
      FROM dream_analyses 
      WHERE user_id = ? 
      GROUP BY DATE(analysis_date)
      ORDER BY date DESC
      LIMIT 30
    ''', [userId]);

    final stats = <String, dynamic>{
      'total': totalResult.first['total'],
      'by_type': <String, int>{},
      'by_model': <String, int>{},
      'by_date': <String, int>{},
    };

    for (final row in byTypeResult) {
      stats['by_type'][row['analysis_type'] as String] = row['count'] as int;
    }

    for (final row in byModelResult) {
      stats['by_model'][row['model_used'] as String] = row['count'] as int;
    }

    for (final row in byDateResult) {
      stats['by_date'][row['date'] as String] = row['count'] as int;
    }

    return stats;
  }

  Future<int> clearDreamAnalysisHistory(String userId) async {
    final db = await _dbService.database;
    return await db.delete(
      'dream_analyses',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  DreamAnalysisModel _mapToDreamAnalysisModel(Map<String, dynamic> row) {
    return DreamAnalysisModel(
      id: row['id'] as int,
      symbols: List<String>.from(jsonDecode(row['symbols_json'] as String)),
      symbolMeanings: Map<String, String>.from(jsonDecode(row['symbol_meanings_json'] as String)),
      emotionScores: Map<String, int>.from(jsonDecode(row['emotion_scores_json'] as String)),
      themes: List<String>.from(jsonDecode(row['themes_json'] as String)),
      subconsciousMessage: row['subconscious_message'] as String,
      summary: row['summary'] as String,
      advice: row['advice'] as String,
      aiReply: row['ai_reply'] as String,
      mindMap: Map<String, List<String>>.fromEntries(
        (jsonDecode(row['mind_map_json'] as String) as Map<String, dynamic>).entries.map(
          (e) => MapEntry(e.key, List<String>.from(e.value ?? [])),
        ),
      ),
      modelUsed: row['model_used'] as String? ?? 'mistral-small-3.2',
      analysisDate: DateTime.parse(row['analysis_date'] as String),
    );
  }
} 