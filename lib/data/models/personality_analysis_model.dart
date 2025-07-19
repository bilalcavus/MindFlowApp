import 'dart:convert';

class PersonalityAnalysisModel {
  final int? id;
  final Map<String, int>? personalityScoreJson;
  final String? dominantTrait;
  final Map<String, int>? secondaryTraitsJson;
  final String? summary;
  final String? advice;
  final String? aiReply;
  final String? modelUsed;
  final DateTime? analysisDate;

  PersonalityAnalysisModel({
    this.id,
    this.personalityScoreJson,
    this.dominantTrait,
    this.secondaryTraitsJson,
    this.summary,
    this.advice,
    this.aiReply,
    this.modelUsed,
    this.analysisDate,
  });

  factory PersonalityAnalysisModel.fromJson(Map<String, dynamic> json) {
  Map<String, int>? parseIntMap(dynamic field) {
    if (field == null) return {};
    if (field is String && field.isNotEmpty) {
      return Map<String, int>.from(jsonDecode(field));
    }
    if (field is Map) {
      return field.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
    }
    return {};
  }

  return PersonalityAnalysisModel(
    id: json['id'],
    personalityScoreJson: parseIntMap(json['personality_score_json']),
    dominantTrait: json['dominant_trait'] ?? '',
    secondaryTraitsJson: parseIntMap(json['secondary_traits_json']),
    summary: json['summary'] ?? '',
    advice: json['advice'] ?? '',
    aiReply: json['ai_reply'],
    modelUsed: json['model_used'] ?? 'unknown',
    analysisDate: DateTime.tryParse(json['analysis_date'] ?? '') ?? DateTime.now(),
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personality_score_json': jsonEncode(personalityScoreJson),
      'dominant_trait': dominantTrait,
      'secondary_traits_json': secondaryTraitsJson != null ? jsonEncode(secondaryTraitsJson) : null,
      'summary': summary,
      'advice': advice,
      'ai_reply': aiReply,
      'model_used': modelUsed,
      'analysis_date': analysisDate?.toIso8601String(),
    };
  }
}
