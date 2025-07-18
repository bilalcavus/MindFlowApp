import 'dart:convert';

class PersonalityAnalysisModel {
  final int? id;
  final Map<String, double>? traitsJson;
  final Map<String, int>? personalityScoreJson;
  final String? dominantTrait;
  final Map<String, int>? secondaryTraitsJson;
  final Map<String, String>? strengthsJson;
  final Map<String, String>? weaknessJson;
  final Map<String, List<String>>? suggestedRoleJson;
  final String? summary;
  final String? advice;
  final String? aiReply;
  final Map<String, List<String>>? mindMapJson;
  final String? modelUsed;
  final DateTime? analysisDate;

  PersonalityAnalysisModel({
    this.id,
    this.traitsJson,
    this.personalityScoreJson,
    this.dominantTrait,
    this.secondaryTraitsJson,
    this.strengthsJson,
    this.weaknessJson,
    this.suggestedRoleJson,
    this.summary,
    this.advice,
    this.aiReply,
    this.mindMapJson,
    this.modelUsed,
    this.analysisDate,
  });

  factory PersonalityAnalysisModel.fromJson(Map<String, dynamic> json) {
    Map<String, double>? parseDoubleMap(dynamic field) {
      if (field == null) return {};
      if (field is String) {
        if (field.isEmpty) return {};
        return Map<String, double>.from(jsonDecode(field));
      }
      if (field is Map) {
        return field.map((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
      }
      return {};
    }
    Map<String, int>? parseIntMap(dynamic field) {
      if (field == null) return {};
      if (field is String) {
        if (field.isEmpty) return {};
        return Map<String, int>.from(jsonDecode(field));
      }
      if (field is Map) {
        return field.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
      }
      return {};
    }
    Map<String, String>? parseStringMap(dynamic field) {
      if (field == null) return {};
      if (field is String) {
        if (field.isEmpty) return {};
        return Map<String, String>.from(jsonDecode(field));
      }
      if (field is Map) {
        return field.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
      return {};
    }
    Map<String, List<String>>? parseStringListMap(dynamic field) {
      if (field == null) return {};
      if (field is String) {
        if (field.isEmpty) return {};
        return Map<String, List<String>>.fromEntries(
          (jsonDecode(field) as Map<String, dynamic>).entries.map(
            (e) => MapEntry(e.key, List<String>.from(e.value)),
          ),
        );
      }
      if (field is Map) {
        return field.map((k, v) => MapEntry(k.toString(), List<String>.from(v)));
      }
      return {};
    }
    return PersonalityAnalysisModel(
      id: json['id'],
      traitsJson: parseDoubleMap(json['traits_json']),
      personalityScoreJson: parseIntMap(json['personality_score_json']),
      dominantTrait: json['dominant_trait'] ?? '',
      secondaryTraitsJson: parseIntMap(json['secondary_traits_json']),
      strengthsJson: parseStringMap(json['strengths_json']),
      weaknessJson: parseStringMap(json['weakness_json']),
      suggestedRoleJson: parseStringListMap(json['suggested_role_json']),
      summary: json['summary'] ?? '',
      advice: json['advice'] ?? '',
      aiReply: json['ai_reply'],
      mindMapJson: parseStringListMap(json['mind_map_json']),
      modelUsed: json['model_used'] ?? 'unknown',
      analysisDate: DateTime.tryParse(json['analysis_date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'traits_json': jsonEncode(traitsJson),
      'personality_score_json': jsonEncode(personalityScoreJson),
      'dominant_trait': dominantTrait,
      'secondary_traits_json': secondaryTraitsJson != null ? jsonEncode(secondaryTraitsJson) : null,
      'strengths_json': jsonEncode(strengthsJson),
      'weakness_json': jsonEncode(weaknessJson),
      'suggested_role_json': suggestedRoleJson != null ? jsonEncode(suggestedRoleJson) : null,
      'summary': summary,
      'advice': advice,
      'ai_reply': aiReply,
      'mind_map_json': jsonEncode(mindMapJson),
      'model_used': modelUsed,
      'analysis_date': analysisDate?.toIso8601String(),
    };
  }
}
