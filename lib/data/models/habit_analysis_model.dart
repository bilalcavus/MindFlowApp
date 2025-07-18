import 'dart:convert';

class HabitAnalysisModel {
  final int? id;
  final String userId;
  final int entryId;
  final String analysisType;
  final List<String> habits;
  final List<String> positiveHabits;
  final List<String> negativeHabits;
  final Map<String, int> habitScores;
  final String lifestyleCategory;
  final String summary;
  final String advice;
  final String? aiReply;
  final Map<String, List<String>> mindMap;
  final String modelUsed;
  final DateTime analysisDate;
  final DateTime createdAt;

  HabitAnalysisModel({
    this.id,
    required this.userId,
    required this.entryId,
    this.analysisType = 'habit',
    required this.habits,
    required this.positiveHabits,
    required this.negativeHabits,
    required this.habitScores,
    required this.lifestyleCategory,
    required this.summary,
    required this.advice,
    this.aiReply,
    required this.mindMap,
    required this.modelUsed,
    required this.analysisDate,
    required this.createdAt,
  });

  factory HabitAnalysisModel.fromJson(Map<String, dynamic> json) {
    return HabitAnalysisModel(
      id: json['id'],
      userId: json['user_id'],
      entryId: json['entry_id'],
      analysisType: json['analysis_type'] ?? 'habit',
      habits: List<String>.from(jsonDecode(json['habits_json'] ?? '[]')),
      positiveHabits: List<String>.from(jsonDecode(json['positive_habits_json'] ?? '[]')),
      negativeHabits: List<String>.from(jsonDecode(json['negative_habits_json'] ?? '[]')),
      habitScores: Map<String, int>.from(jsonDecode(json['habit_scores_json'] ?? '{}')),
      lifestyleCategory: json['lifestyle_category'] ?? '',
      summary: json['summary'] ?? '',
      advice: json['advice'] ?? '',
      aiReply: json['ai_reply'],
      mindMap: Map<String, List<String>>.fromEntries(
        (jsonDecode(json['mind_map_json'] ?? '{}') as Map<String, dynamic>).entries.map(
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
      'habits_json': jsonEncode(habits),
      'positive_habits_json': jsonEncode(positiveHabits),
      'negative_habits_json': jsonEncode(negativeHabits),
      'habit_scores_json': jsonEncode(habitScores),
      'lifestyle_category': lifestyleCategory,
      'summary': summary,
      'advice': advice,
      'ai_reply': aiReply,
      'mind_map_json': jsonEncode(mindMap),
      'model_used': modelUsed,
      'analysis_date': analysisDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
