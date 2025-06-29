class EmotionAnalysisModel {
  final List<String> emotions;
  final List<String> themes;
  final String advice;
  final Map<String, List<String>> mindMap;
  final String summary;
  final String modelUsed;
  final DateTime analysisDate;

  EmotionAnalysisModel({
    required this.emotions,
    required this.themes,
    required this.advice,
    required this.mindMap,
    required this.summary,
    required this.modelUsed,
    required this.analysisDate,
  });

  factory EmotionAnalysisModel.fromJson(Map<String, dynamic> json) {
    return EmotionAnalysisModel(
      emotions: List<String>.from(json['emotions'] ?? []),
      themes: List<String>.from(json['key_themes'] ?? []),
      advice: json['advice'] ?? '',
      mindMap: Map<String, List<String>>.fromEntries(
        (json['mind_map'] as Map<String, dynamic>? ?? {}).entries.map(
          (e) => MapEntry(e.key, List<String>.from(e.value ?? [])),
        ),
      ),
      summary: json['summary'] ?? '',
      modelUsed: json['model_used'] ?? 'unknown',
      analysisDate: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emotions': emotions,
      'key_themes': themes,
      'advice': advice,
      'mind_map': mindMap,
      'summary': summary,
      'model_used': modelUsed,
      'analysis_date': analysisDate.toIso8601String(),
    };
  }
}
