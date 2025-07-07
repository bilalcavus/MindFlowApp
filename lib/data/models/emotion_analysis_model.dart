class EmotionAnalysisModel {
  final int? id;
  final Map<String, int> emotions;
  final List<String> themes;
  final String advice;
  final Map<String, List<String>> mindMap;
  final String summary;
  final String modelUsed;
  final DateTime analysisDate;

  EmotionAnalysisModel({
    this.id,
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
      id: json['id'],
      emotions: Map<String, int>.from(json['emotions'] ?? []),
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
      'id': id,
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
