import 'dart:convert';

import 'package:mind_flow/core/services/database_service.dart';
import 'package:mind_flow/data/models/stress_analysis_model.dart';

class StressAnalysisRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<int> insertStressAnalysis({
    required String userId,
    required int entryId,
    required String analysisType,
    required StressAnalysisModel analysis,
    String? modelUsed,
  }) async {
    final db = await _dbService.database;
    return await db.insert(
      'stress_analyses',
      {
        'user_id': userId,
        'entry_id': entryId,
        'analysis_type': analysisType,
        'stress_level': analysis.stressLevel,
        'burnout_risk': analysis.burnoutRisk,
        'stress_factors': jsonEncode(analysis.stressFactors),
        'coping_strategies': jsonEncode(analysis.copingStrategies),
        'risk_scores_json': jsonEncode(analysis.riskScores),
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

  Future<int> updateStressAnalysis({
    required int id,
    required StressAnalysisModel analysis,
  }) async {
    final db = await _dbService.database;
    return await db.update(
      'stress_analyses',
      {
        'stress_level': analysis.stressLevel,
        'burnout_risk': analysis.burnoutRisk,
        'stress_factors': jsonEncode(analysis.stressFactors),
        'coping_strategies': jsonEncode(analysis.copingStrategies),
        'risk_scores_json': jsonEncode(analysis.riskScores),
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

  Future<StressAnalysisModel?> getStressAnalysisById(int id) async {
    final db = await _dbService.database;
    final results = await db.query(
      'stress_analyses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) {
      return null;
    }
    return _mapToStressAnalysisModel(results.first);
  }

  Future<StressAnalysisModel?> getStressAnalysisByEntryId(int entryId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'stress_analyses',
      where: 'entry_id = ?',
      whereArgs: [entryId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return _mapToStressAnalysisModel(results.first);
  }

  Future<List<StressAnalysisModel>> getStressAnalysesByType({
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
      'stress_analyses',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'analysis_date DESC',
      limit: limit,
    );
    return results.map((row) => _mapToStressAnalysisModel(row)).toList();
  }

  Future<List<StressAnalysisModel>> getAllStressAnalyses({
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
      'stress_analyses',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'analysis_date DESC',
      limit: limit,
    );
    return results.map((row) => _mapToStressAnalysisModel(row)).toList();
  }

  Future<int> deleteStressAnalysis(String userId) async {
    final db = await _dbService.database;
    return await db.delete(
      'stress_analyses',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  StressAnalysisModel _mapToStressAnalysisModel(Map<String, dynamic> row) {
    return StressAnalysisModel.fromJson({
      'id': row['id'],
      'stress_level': row['stress_level'],
      'burnout_risk': row['burnout_risk'],
      'stress_factors': jsonDecode(row['stress_factors'] ?? '[]'),
      'coping_strategies': jsonDecode(row['coping_strategies'] ?? '[]'),
      'risk_scores_json': jsonDecode(row['risk_scores_json'] ?? '{}'),
      'summary': row['summary'],
      'advice': row['advice'],
      'ai_reply': row['ai_reply'],
      'mind_map': jsonDecode(row['mind_map'] ?? '{}'),
      'model_used': row['model_used'],
      'analysis_date': row['analysis_date'],
    });
  }
} 