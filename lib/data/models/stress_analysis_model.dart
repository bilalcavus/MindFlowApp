import 'dart:convert';

class StressAnalysisModel {
  final int? id;
  final String userId;
  final int entryId;
  final String analysisType;
  final double stressLevel;
  final double burnoutRisk;
  final List<String> stressFactors;
  final List<String> copingStrategies;
  final Map<String, int> riskScores;
  final String summary;
  final String advice;
  final String? aiReply;
  final Map<String, List<String>> mindMap;
  final String modelUsed;
  final DateTime analysisDate;
  final DateTime createdAt;

  StressAnalysisModel({
    this.id,
    required this.userId,
    required this.entryId,
    this.analysisType = 'stress',
    required this.stressLevel,
    required this.burnoutRisk,
    required this.stressFactors,
    required this.copingStrategies,
    required this.riskScores,
    required this.summary,
    required this.advice,
    this.aiReply,
    required this.mindMap,
    required this.modelUsed,
    required this.analysisDate,
    required this.createdAt,
  });

  factory StressAnalysisModel.fromJson(Map<String, dynamic> json) {
    return StressAnalysisModel(
      id: json['id'],
      userId: json['user_id'],
      entryId: json['entry_id'],
      analysisType: json['analysis_type'] ?? 'stress',
      stressLevel: (json['stress_level'] ?? 0.0).toDouble(),
      burnoutRisk: (json['burnout_risk'] ?? 0.0).toDouble(),
      stressFactors: List<String>.from(jsonDecode(json['stress_factors'] ?? '[]')),
      copingStrategies: List<String>.from(jsonDecode(json['coping_strategies'] ?? '[]')),
      riskScores: Map<String, int>.from(jsonDecode(json['risk_scores_json'] ?? '{}')),
      summary: json['summary'] ?? '',
      advice: json['advice'] ?? '',
      aiReply: json['ai_reply'],
      mindMap: Map<String, List<String>>.fromEntries(
        (jsonDecode(json['mind_map'] ?? '{}') as Map<String, dynamic>).entries.map(
          (e) => MapEntry(e.key, List<String>.from(e.value ?? [])),
        ),
      ),
      modelUsed: json['model_used'] ?? 'unknown',
      analysisDate: DateTime.tryParse(json['analysis_date'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'entry_id': entryId,
      'analysis_type': analysisType,
      'stress_level': stressLevel,
      'burnout_risk': burnoutRisk,
      'stress_factors': jsonEncode(stressFactors),
      'coping_strategies': jsonEncode(copingStrategies),
      'risk_scores_json': jsonEncode(riskScores),
      'summary': summary,
      'advice': advice,
      'ai_reply': aiReply,
      'mind_map': jsonEncode(mindMap),
      'model_used': modelUsed,
      'analysis_date': analysisDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
