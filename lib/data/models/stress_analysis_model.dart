import 'dart:convert';

class StressAnalysisModel {
  final int? id;

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

  StressAnalysisModel({
    this.id,
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
  });

  factory StressAnalysisModel.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is String) {
        return List<String>.from(jsonDecode(value));
      } else if (value is List) {
        return List<String>.from(value);
      }
      return [];
    }

    Map<String, int> parseIntMap(dynamic value) {
      if (value == null) return {};
      if (value is String) {
        return Map<String, int>.from(jsonDecode(value));
      } else if (value is Map) {
        return value.map((k, v) => MapEntry(
            k.toString(), v is int ? v : int.tryParse(v.toString()) ?? 0));
      }
      return {};
    }

    Map<String, List<String>> parseMindMap(dynamic value) {
      if (value == null) return {};
      if (value is String) {
        final decoded = jsonDecode(value) as Map<String, dynamic>;
        return decoded.map(
            (k, v) => MapEntry(k.toString(), List<String>.from(v ?? [])));
      } else if (value is Map) {
        return value.map((k, v) =>
            MapEntry(k.toString(), List<String>.from(v ?? [])));
      }
      return {};
    }

    return StressAnalysisModel(
      id: json['id'],
      stressLevel: (json['stress_level'] ?? 0.0).toDouble(),
      burnoutRisk: (json['burnout_risk'] ?? 0.0).toDouble(),
      stressFactors: parseStringList(json['stress_factors']),
      copingStrategies: parseStringList(json['coping_strategies']),
      riskScores: parseIntMap(json['risk_scores_json']),
      summary: json['summary'] ?? '',
      advice: json['advice'] ?? '',
      aiReply: json['ai_reply'],
      mindMap: parseMindMap(json['mind_map']),
      modelUsed: json['model_used'] ?? 'unknown',
      analysisDate:
          DateTime.tryParse(json['analysis_date'] ?? '') ?? DateTime.now(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    };
  }
}
