import 'dart:convert';

class MentalAnalysisModel {
  final int? id;
  final String userId;
  final int entryId;
  final String analysisType;
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
  final DateTime createdAt;

  MentalAnalysisModel({
    this.id,
    required this.userId,
    required this.entryId,
    this.analysisType = 'mental',
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
    required this.createdAt,
  });

  factory MentalAnalysisModel.fromJson(Map<String, dynamic> json) {
    return MentalAnalysisModel(
      id: json['id'],
      userId: json['user_id'],
      entryId: json['entry_id'],
      analysisType: json['analysis_type'] ?? 'mental',
      mentalScores: Map<String, int>.from(jsonDecode(json['mental_scores_json'] ?? '{}')),
      cognitivePatterns: List<String>.from(jsonDecode(json['cognitive_patterns'] ?? '[]')),
      mentalChallenges: List<String>.from(jsonDecode(json['mental_challenges'] ?? '[]')),
      themes: List<String>.from(jsonDecode(json['themes'] ?? '[]')),
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
      'created_at': createdAt.toIso8601String(),
    };
  }
}
