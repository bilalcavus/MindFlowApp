import 'dart:convert';

class HabitAnalysisModel {
  final int? id;
  final List<String> habits;
  final List<String> positiveHabits;
  final List<String> negativeHabits;
  final Map<String, int> habitScores;
  final String lifestyleCategory;
  final String summary;
  final String advice;
  final String? aiReply;
  final String modelUsed;
  final DateTime analysisDate;

  HabitAnalysisModel({
    this.id,
    required this.habits,
    required this.positiveHabits,
    required this.negativeHabits,
    required this.habitScores,
    required this.lifestyleCategory,
    required this.summary,
    required this.advice,
    this.aiReply,
    required this.modelUsed,
    required this.analysisDate,
  });

  factory HabitAnalysisModel.fromJson(Map<String, dynamic> json) {
    return HabitAnalysisModel(
      id: json['id'],
      habits: List<String>.from(jsonDecode(json['habits_json']?.toString() ?? '[]')),
      positiveHabits: List<String>.from(jsonDecode(json['positive_habits_json']?.toString() ?? '[]')),
      negativeHabits: List<String>.from(jsonDecode(json['negative_habits_json']?.toString() ?? '[]')),
      habitScores: Map<String, int>.from(jsonDecode(json['habit_scores_json']?.toString() ?? '{}')),
      lifestyleCategory: json['lifestyle_category'] ?? '',
      summary: json['summary'] ?? '',
      advice: json['advice'] ?? '',
      aiReply: json['ai_reply'],
      modelUsed: json['model_used'] ?? 'unknown',
      analysisDate: DateTime.tryParse(json['analysis_date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habits_json': jsonEncode(habits),
      'positive_habits_json': jsonEncode(positiveHabits),
      'negative_habits_json': jsonEncode(negativeHabits),
      'habit_scores_json': jsonEncode(habitScores),
      'lifestyle_category': lifestyleCategory,
      'summary': summary,
      'advice': advice,
      'ai_reply': aiReply,
      'model_used': modelUsed,
      'analysis_date': analysisDate.toIso8601String(),
    };
  }
}
