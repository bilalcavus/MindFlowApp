import 'dart:convert';

import 'package:mind_flow/core/services/database_service.dart';
import 'package:mind_flow/data/models/mental_analysis_model.dart';

class MentalAnalysisRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<int> insertMentalAnalysis({
    required String userId,
    required int entryId,
    required String analysisType,
    required MentalAnalysisModel analysis,
    String? modelUsed,
  }) async {
    final db = await _dbService.database;
    return await db.insert(
      'mental_analyses',
      {
        'user_id': userId,
        'entry_id': entryId,
        'analysis_type': analysisType,
        'mental_scores_json': jsonEncode(analysis.mentalScores),
        'cognitive_patterns': jsonEncode(analysis.cognitivePatterns),
        'mental_challenges': jsonEncode(analysis.mentalChallenges),
        'themes': jsonEncode(analysis.themes),
        'summary': analysis.summary,
        'advice': analysis.advice,
        'ai_reply': analysis.aiReply,
        'mind_map': jsonEncode(analysis.mindMap),
        'model_used': modelUsed ?? analysis.modelUsed,
        'analysis_date': analysis.analysisDate.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<int> updateMentalAnalysis({
    required int id,
    required MentalAnalysisModel analysis,
  }) async {
    final db = await _dbService.database;
    return await db.update(
      'mental_analyses',
      {
        'mental_scores_json': jsonEncode(analysis.mentalScores),
        'cognitive_patterns': jsonEncode(analysis.cognitivePatterns),
        'mental_challenges': jsonEncode(analysis.mentalChallenges),
        'themes': jsonEncode(analysis.themes),
        'summary': analysis.summary,
        'advice': analysis.advice,
        'ai_reply': analysis.aiReply,
        'mind_map': jsonEncode(analysis.mindMap),
        'model_used': analysis.modelUsed,
        'analysis_date': analysis.analysisDate.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<MentalAnalysisModel?> getMentalAnalysisById(int id) async {
    final db = await _dbService.database;
    final results = await db.query(
      'mental_analyses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) {
      return null;
    }
    return _mapToMentalAnalysisModel(results.first);
  }

  Future<MentalAnalysisModel?> getMentalAnalysisByEntryId(int entryId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'mental_analyses',
      where: 'entry_id = ?',
      whereArgs: [entryId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return _mapToMentalAnalysisModel(results.first);
  }

  Future<List<MentalAnalysisModel>> getMentalAnalysesByType({
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
      'mental_analyses',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'analysis_date DESC',
      limit: limit,
    );
    return results.map((row) => _mapToMentalAnalysisModel(row)).toList();
  }

  Future<List<MentalAnalysisModel>> getAllMentalAnalyses({
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
      'mental_analyses',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'analysis_date DESC',
      limit: limit,
    );
    return results.map((row) => _mapToMentalAnalysisModel(row)).toList();
  }

  Future<int> deleteMentalAnalysis(String userId) async {
    final db = await _dbService.database;
    return await db.delete(
      'mental_analyses',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  MentalAnalysisModel _mapToMentalAnalysisModel(Map<String, dynamic> row) {
    return MentalAnalysisModel.fromJson({
      'id': row['id'],
      'mental_scores_jon': jsonDecode(row['mental_scores_json'] ?? '{}'),
      'cognitive_patterns': jsonDecode(row['cognitive_patterns'] ?? '[]'),
      'mental_challenges': jsonDecode(row['mental_challenges'] ?? '[]'),
      'themes': jsonDecode(row['themes'] ?? '[]'),
      'summary': row['summary'],
      'advice': row['advice'],
      'ai_reply': row['ai_reply'],
      'mind_map': jsonDecode(row['mind_map'] ?? '{}'),
      'model_used': row['model_used'],
      'analysis_date': row['analysis_date'],
    });
  }
} 