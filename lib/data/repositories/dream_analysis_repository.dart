import 'dart:convert';

import 'package:mind_flow/core/services/database_service.dart';
import 'package:mind_flow/data/models/dream_analysis_model.dart';

class DreamAnalysisDataRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<int> insertDreamAnalysis({
    required int entryId,
    required DreamAnalysisModel analysis,
  }) async {
    final db = await _dbService.database;

    return await db.insert(
      'dream_analyses',
      {
        'entry_id': entryId,
        'symbols_json': jsonEncode(analysis.symbols),
        'symbol_meanings_json': jsonEncode(analysis.symbolMeanings),
        'emotion_scores_json': jsonEncode(analysis.emotionScores),
        'themes_json': jsonEncode(analysis.themes),
        'subconscious_message': analysis.subconsciousMessage,
        'summary': analysis.summary,
        'advice': analysis.advice,
        'ai_reply': analysis.aiReply,
        'mind_map_json': jsonEncode(analysis.mindMap),
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
        'analysis_date': analysis.analysisDate.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<DreamAnalysisModel?> getDreamAnalysisById(int id) async {
    final db = await _dbService.database;
    final results = await db.query(
      'dream_analyses',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;

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

  Future<Map<String, dynamic>> getDreamAnalysisStats() async {
    final db = await _dbService.database;
    final totalResult = await db.rawQuery('SELECT COUNT(*) as total FROM dream_analyses');
    final total = totalResult.first['total'] as int;
    final monthlyResults = await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', analysis_date) as month,
        COUNT(*) as count
      FROM dream_analyses
      GROUP BY strftime('%Y-%m', analysis_date)
      ORDER BY month DESC
      LIMIT 12
    ''');

    final monthlyStats = <String, int>{};
    for (final row in monthlyResults) {
      monthlyStats[row['month'] as String] = row['count'] as int;
    }

    return {
      'total': total,
      'monthly': monthlyStats,
      'most_common_symbols': await getMostCommonSymbols(limit: 10),
      'most_common_themes': await getMostCommonThemes(limit: 10),
    };
  }

  DreamAnalysisModel _mapToDreamAnalysisModel(Map<String, dynamic> row) {
    return DreamAnalysisModel(
      symbols: List<String>.from(jsonDecode(row['symbols_json'])),
      symbolMeanings: Map<String, String>.from(jsonDecode(row['symbol_meanings_json'])),
      emotionScores: Map<String, int>.from(jsonDecode(row['emotion_scores_json'])),
      themes: List<String>.from(jsonDecode(row['themes_json'])),
      subconsciousMessage: row['subconscious_message'],
      summary: row['summary'],
      advice: row['advice'],
      aiReply: row['ai_reply'],
      mindMap: Map<String, List<String>>.from(
        (jsonDecode(row['mind_map_json']) as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      analysisDate: DateTime.parse(row['analysis_date']),
    );
  }
} 