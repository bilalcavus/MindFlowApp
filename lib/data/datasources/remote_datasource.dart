import 'package:mind_flow/data/models/dream_analysis_model.dart';
import 'package:mind_flow/data/models/emotion_analysis_model.dart';

abstract class RemoteDataSource {
  Future<EmotionAnalysisModel> analyzeEmotion(String userText, {String? modelKey});
  Future<DreamAnalysisModel> analyzeDream(String userText, {String? modelKey});
  Future<String> getChatResponse(String userMessage, {String? modelKey});
  Future<String> getChatResponseWithContext(List<Map<String, String>> messages, {String? modelKey, String? chatType});
  List<String> getAvailableModels();
  String getModelDisplayName(String modelKey);
  String getCurrentProvider();
  List<String> getAvailableProviders();
} 