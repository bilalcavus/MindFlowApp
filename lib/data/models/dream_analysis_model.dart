class DreamAnalysisModel {
  final int? id;
  final List<String> symbols;
  final Map<String, String> symbolMeanings;
  final Map<String, int> emotionScores;
  final List<String> themes;
  final String subconsciousMessage;
  final String summary;
  final String advice;
  final String aiReply;
  final Map<String, List<String>> mindMap;
  final String modelUsed;
  final DateTime analysisDate;

  DreamAnalysisModel({
    this.id,
    required this.symbols,
    required this.symbolMeanings,
    required this.emotionScores,
    required this.themes,
    required this.subconsciousMessage,
    required this.summary,
    required this.advice,
    required this.aiReply,
    required this.mindMap,
    required this.modelUsed,
    required this.analysisDate,
  });

  factory DreamAnalysisModel.fromJson(Map<String, dynamic> json) {
    return DreamAnalysisModel(
      id: json['id'],
      symbols: List<String>.from(json['symbols'] ?? []),
      symbolMeanings: Map<String, String>.from(json['symbol_meanings'] ?? {}),
      emotionScores: Map<String, int>.from(json['emotion_scores'] ?? {}),
      themes: List<String>.from(json['themes'] ?? []),
      subconsciousMessage: json['subconscious_message'] ?? '',
      summary: json['summary'] ?? '',
      advice: json['advice'] ?? '',
      aiReply: json['ai_reply'] ?? '',
      mindMap: Map<String, List<String>>.fromEntries(
        (json['mind_map'] as Map<String, dynamic>? ?? {}).entries.map(
          (e) => MapEntry(e.key, List<String>.from(e.value ?? [])),
        ),
      ),
      modelUsed: json['model_used'] ?? 'unknown',
      analysisDate: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbols': symbols,
      'symbol_meanings': symbolMeanings,
      'emotion_scores': emotionScores,
      'themes': themes,
      'subconscious_message': subconsciousMessage,
      'summary': summary,
      'advice': advice,
      'ai_reply': aiReply,
      'mind_map': mindMap,
      'model_used': modelUsed,
      'analysis_date': analysisDate.toIso8601String(),
    };
  }
}
