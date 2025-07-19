import 'dart:convert';

class MentalAnalysisModel {
  final int? id;
  final Map<String, int> mentalScores;
  final List<String> cognitivePatterns;
  final List<String> mentalChallenges;
  final List<String> themes;
  final String summary;
  final String advice;
  final String? aiReply;
  final Map<String, List<String>> mindMap;
  final String modelUsed;
  final DateTime analysisDate;

  MentalAnalysisModel({
    this.id,
    required this.mentalScores,
    required this.cognitivePatterns,
    required this.mentalChallenges,
    required this.themes,
    required this.summary,
    required this.advice,
    this.aiReply,
    required this.mindMap,
    required this.modelUsed,
    required this.analysisDate,
  });

  factory MentalAnalysisModel.fromJson(Map<String, dynamic> json) {
  Map<String, int> parseIntMap(dynamic value) {
    if (value == null) return {};
    if (value is String) {
      return Map<String, int>.from(jsonDecode(value));
    } else if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), (v is int) ? v : int.tryParse(v.toString()) ?? 0));
    }
    return {};
  }

  List<String> parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is String) {
      return List<String>.from(jsonDecode(value));
    } else if (value is List) {
      return List<String>.from(value);
    }
    return [];
  }

  Map<String, List<String>> parseMindMap(dynamic value) {
    if (value == null) return {};
    if (value is String) {
      final decoded = jsonDecode(value) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, List<String>.from(v ?? [])));
    } else if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), List<String>.from(v ?? [])));
    }
    return {};
  }

  return MentalAnalysisModel(
    id: json['id'],
    mentalScores: parseIntMap(json['mental_scores_json']),
    cognitivePatterns: parseStringList(json['cognitive_patterns']),
    mentalChallenges: parseStringList(json['mental_challenges']),
    themes: parseStringList(json['themes']),
    summary: json['summary'] ?? '',
    advice: json['advice'] ?? '',
    aiReply: json['ai_reply'],
    mindMap: parseMindMap(json['mind_map']),
    modelUsed: json['model_used'] ?? 'unknown',
    analysisDate: DateTime.tryParse(json['analysis_date'] ?? '') ?? DateTime.now(),
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mental_scores_json': jsonEncode(mentalScores),
      'cognitive_patterns': jsonEncode(cognitivePatterns),
      'mental_challenges': jsonEncode(mentalChallenges),
      'themes': jsonEncode(themes),
      'summary': summary,
      'advice': advice,
      'ai_reply': aiReply,
      'mind_map': jsonEncode(mindMap),
      'model_used': modelUsed,
      'analysis_date': analysisDate.toIso8601String(),
    };
  }
}
