import 'dart:convert';

import 'package:mind_flow/core/services/database_service.dart';
import 'package:mind_flow/data/models/habit_analysis_model.dart';

class HabitAnalysisRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<int> insertHabitAnalysis({
    required String userId,
    required int entryId,
    required String analysisType,
    required HabitAnalysisModel analysis,
    String? modelUsed,
  }) async {
    final db = await _dbService.database;
    return await db.insert(
      'habit_analyses',
      {
        'user_id': userId,
        'entry_id': entryId,
        'analysis_type': analysisType,
        'habits_json': jsonEncode(analysis.habits),
        'positive_habits_json': jsonEncode(analysis.positiveHabits),
        'negative_habits_json': jsonEncode(analysis.negativeHabits),
        'habit_scores_json': jsonEncode(analysis.habitScores),
        'lifestyle_category': analysis.lifestyleCategory,
        'summary': analysis.summary,
        'advice': analysis.advice,
        'ai_reply': analysis.aiReply,
        'model_used': modelUsed ?? analysis.modelUsed,
        'analysis_date': analysis.analysisDate.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<int> updateHabitAnalysis({
    required int id,
    required HabitAnalysisModel analysis,
  }) async {
    final db = await _dbService.database;
    return await db.update(
      'habit_analyses',
      {
        'habits_json': jsonEncode(analysis.habits),
        'positive_habits_json': jsonEncode(analysis.positiveHabits),
        'negative_habits_json': jsonEncode(analysis.negativeHabits),
        'habit_scores_json': jsonEncode(analysis.habitScores),
        'lifestyle_category': analysis.lifestyleCategory,
        'summary': analysis.summary,
        'advice': analysis.advice,
        'ai_reply': analysis.aiReply,
        'model_used': analysis.modelUsed,
        'analysis_date': analysis.analysisDate.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<HabitAnalysisModel?> getHabitAnalysisById(int id) async {
    final db = await _dbService.database;
    final results = await db.query(
      'habit_analyses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) {
      return null;
    }
    return _mapToHabitAnalysisModel(results.first);
  }

  Future<HabitAnalysisModel?> getHabitAnalysisByEntryId(int entryId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'habit_analyses',
      where: 'entry_id = ?',
      whereArgs: [entryId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return _mapToHabitAnalysisModel(results.first);
  }

  Future<List<HabitAnalysisModel>> getHabitAnalysesByType({
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
      'habit_analyses',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'analysis_date DESC',
      limit: limit,
    );
    return results.map((row) => _mapToHabitAnalysisModel(row)).toList();
  }

  Future<List<HabitAnalysisModel>> getAllHabitAnalyses({
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
      'habit_analyses',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'analysis_date DESC',
      limit: limit,
    );
    return results.map((row) => _mapToHabitAnalysisModel(row)).toList();
  }

  Future<int> deleteHabitAnalysis(String userId) async {
    final db = await _dbService.database;
    return await db.delete(
      'habit_analyses',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  HabitAnalysisModel _mapToHabitAnalysisModel(Map<String, dynamic> row) {
    return HabitAnalysisModel.fromJson({
      'id': row['id'],
      'habits_json': row['habits_json'] ?? '[]',
      'user_id': row['user_id'] ?? '',
      'entry_id': row['entry_id'] ?? '',
      'analysis_type': row['analysis_type'] ?? '',
      'positive_habits_json': row['positive_habits_json'] ?? '[]',
      'negative_habits_json': row['negative_habits_json'] ?? '[]',
      'habit_scores_json': row['habit_scores_json'] ?? '{}',
      'lifestyle_category': row['lifestyle_category'] ?? '',
      'summary': row['summary'] ?? '',
      'advice': row['advice'] ?? '',
      'ai_reply': row['ai_reply'] ?? '',
      'model_used': row['model_used'],
      'analysis_date': row['analysis_date'],
    });
  }
} 