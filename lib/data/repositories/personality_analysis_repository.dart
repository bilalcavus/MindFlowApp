import 'dart:convert';

import 'package:mind_flow/core/services/database_service.dart';
import 'package:mind_flow/data/models/personality_analysis_model.dart';

class PersonalityAnalysisRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<int> insertPersonalityAnalysis({
    required String userId,
    required int entryId,
    required String analysisType,
    required PersonalityAnalysisModel analysis,
    String? modelUsed,
  }) async {
    final db = await _dbService.database;
    return await db.insert(
      'personality_analyses',
      {
        'user_id': userId,
        'entry_id': entryId,
        'analysis_type': analysisType,
        'traits_json': jsonEncode(analysis.traitsJson),
        'personality_score_json': jsonEncode(analysis.personalityScoreJson),
        'dominant_trait': analysis.dominantTrait,
        'secondary_traits_json': analysis.secondaryTraitsJson != null ? jsonEncode(analysis.secondaryTraitsJson) : null,
        'strengths_json': jsonEncode(analysis.strengthsJson),
        'weakness_json': jsonEncode(analysis.weaknessJson),
        'suggested_role_json': analysis.suggestedRoleJson != null ? jsonEncode(analysis.suggestedRoleJson) : null,
        'summary': analysis.summary,
        'advice': analysis.advice,
        'ai_reply': analysis.aiReply,
        'mind_map_json': jsonEncode(analysis.mindMapJson),
        'model_used': modelUsed ?? analysis.modelUsed,
        'analysis_date': analysis.analysisDate?.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<int> updatePersonalityAnalysis({
    required int id,
    required PersonalityAnalysisModel analysis,
  }) async {
    final db = await _dbService.database;
    return await db.update(
      'personality_analyses',
      {
        'traits_json': jsonEncode(analysis.traitsJson),
        'personality_score_json': jsonEncode(analysis.personalityScoreJson),
        'dominant_trait': analysis.dominantTrait,
        'secondary_traits_json': analysis.secondaryTraitsJson != null ? jsonEncode(analysis.secondaryTraitsJson) : null,
        'strengths_json': jsonEncode(analysis.strengthsJson),
        'weakness_json': jsonEncode(analysis.weaknessJson),
        'suggested_role_json': analysis.suggestedRoleJson != null ? jsonEncode(analysis.suggestedRoleJson) : null,
        'summary': analysis.summary,
        'advice': analysis.advice,
        'ai_reply': analysis.aiReply,
        'mind_map_json': jsonEncode(analysis.mindMapJson),
        'model_used': analysis.modelUsed,
        'analysis_date': analysis.analysisDate?.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<PersonalityAnalysisModel?> getPersonalityAnalysisById(int id) async {
    final db = await _dbService.database;
    final results = await db.query(
      'personality_analyses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) {
      return null;
    }
    return _mapToPersonalityAnalysisModel(results.first);
  }

  Future<PersonalityAnalysisModel?> getPersonalityAnalysisByEntryId(int entryId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'personality_analyses',
      where: 'entry_id = ?',
      whereArgs: [entryId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return _mapToPersonalityAnalysisModel(results.first);
  }

  Future<List<PersonalityAnalysisModel>> getPersonalityAnalysesByType({
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
      'personality_analyses',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'analysis_date DESC',
      limit: limit,
    );
    return results.map((row) => _mapToPersonalityAnalysisModel(row)).toList();
  }

  Future<List<PersonalityAnalysisModel>> getAllPersonalityAnalyses({
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
      'personality_analyses',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'analysis_date DESC',
      limit: limit,
    );
    return results.map((row) => _mapToPersonalityAnalysisModel(row)).toList();
  }

  Future<int> deletePersonalityAnalysis(String userId) async {
    final db = await _dbService.database;
    return await db.delete(
      'personality_analyses',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  PersonalityAnalysisModel _mapToPersonalityAnalysisModel(Map<String, dynamic> row) {
    return PersonalityAnalysisModel.fromJson({
      'id': row['id'],
      'traits': jsonDecode(row['traits_json'] ?? '{}'),
      'personality_score_json': jsonDecode(row['personality_score_json'] ?? '{}'),
      'dominant_trait': row['dominant_trait'],
      'secondary_traits': row['secondary_traits_json'] != null ? jsonDecode(row['secondary_traits_json']) : null,
      'strengths': jsonDecode(row['strengths_json'] ?? '{}'),
      'weaknesses': jsonDecode(row['weakness_json'] ?? '{}'),
      'suggested_roles': row['suggested_role_json'] != null ? jsonDecode(row['suggested_role_json']) : null,
      'summary': row['summary'],
      'advice': row['advice'],
      'ai_reply': row['ai_reply'],
      'mind_map': jsonDecode(row['mind_map_json'] ?? '{}'),
      'model_used': row['model_used'],
      'analysis_date': row['analysis_date'],
    });
  }
} 