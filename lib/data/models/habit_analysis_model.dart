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
      habits: _parseStringList(json['habits_json']),
      positiveHabits: _parseStringList(json['positive_habits_json']),
      negativeHabits: _parseStringList(json['negative_habits_json']),
      habitScores: _parseStringIntMap(json['habit_scores_json']),
      lifestyleCategory: json['lifestyle_category'] ?? '',
      summary: json['summary'] ?? '',
      advice: json['advice'] ?? '',
      aiReply: json['ai_reply'],
      modelUsed: json['model_used'] ?? 'unknown',
      analysisDate: DateTime.tryParse(json['analysis_date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static List<String> _parseStringList(dynamic jsonData) {
    if (jsonData == null) return [];
    
    try {
      if (jsonData is List) {
        return jsonData.map((e) => e.toString()).toList();
      }
      
      if (jsonData is String) {
        String data = jsonData.trim();
        
        if (data.startsWith('[') && data.endsWith(']')) {
          try {
            final decoded = jsonDecode(data);
            if (decoded is List) {
              return decoded.map((e) => e.toString()).toList();
            }
          } catch (jsonError) {
            return _parsePythonStyleList(data);
          }
        } else {
          return data.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        }
      }
      
      return [];
    } catch (e) {
      // print('Error parsing string list: $e');
      // print('Input data: $jsonData');
      return [];
    }
  }

  static List<String> _parsePythonStyleList(String data) {
    try {
      // Remove the outer brackets
      String content = data.substring(1, data.length - 1);
      
      // Split by comma and clean up each item
      List<String> items = [];
      String currentItem = '';
      bool inQuotes = false;
      
      for (int i = 0; i < content.length; i++) {
        String currentChar = content[i];
        
        if (currentChar == '"' || currentChar == "'") {
          inQuotes = !inQuotes;
        } else if (currentChar == ',' && !inQuotes) {
          items.add(currentItem.trim());
          currentItem = '';
        } else {
          currentItem += currentChar;
        }
      }
      
      // Add the last item
      if (currentItem.isNotEmpty) {
        items.add(currentItem.trim());
      }
      
      // Clean up quotes from items
      return items.map((item) {
        String cleaned = item.trim();
        if ((cleaned.startsWith('"') && cleaned.endsWith('"')) ||
            (cleaned.startsWith("'") && cleaned.endsWith("'"))) {
          cleaned = cleaned.substring(1, cleaned.length - 1);
        }
        return cleaned;
      }).where((item) => item.isNotEmpty).toList();
      
    } catch (e) {
      return [];
    }
  }

  static Map<String, int> _parseStringIntMap(dynamic jsonData) {
    if (jsonData == null) return {};
    
    try {
      // If it's already a Map, return it directly
      if (jsonData is Map) {
        return jsonData.map((key, value) => MapEntry(key.toString(), int.tryParse(value.toString()) ?? 0));
      }
      
      // If it's a string, try to parse as JSON
      if (jsonData is String) {
        if (jsonData.startsWith('{') && jsonData.endsWith('}')) {
          final decoded = jsonDecode(jsonData);
          if (decoded is Map) {
            return decoded.map((key, value) => MapEntry(key.toString(), int.tryParse(value.toString()) ?? 0));
          }
        }
      }
      
      return {};
    } catch (e) {
      return {};
    }
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
