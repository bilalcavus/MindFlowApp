import 'package:mind_flow/data/models/dream_analysis_model.dart';
import 'package:mind_flow/data/models/emotion_analysis_model.dart';
import 'package:mind_flow/data/models/habit_analysis_model.dart';
import 'package:mind_flow/data/models/mental_analysis_model.dart';
import 'package:mind_flow/data/models/personality_analysis_model.dart';
import 'package:mind_flow/data/models/stress_analysis_model.dart';

abstract class RemoteDataSource {
  Future<EmotionAnalysisModel> analyzeEmotion(String userText, {String? modelKey});
  Future<DreamAnalysisModel> analyzeDream(String userText, {String? modelKey});
  Future<PersonalityAnalysisModel> analyzePersonality(String userText, {String? modelKey});
  Future<MentalAnalysisModel> analyzeMentality(String userText, {String? modelKey});
  Future<HabitAnalysisModel> analyzeHabit(String userText, {String? modelKey});
  Future<StressAnalysisModel> analyzeStress(String userText, {String? modelKey});
  Future<String> getChatResponse(String userMessage, {String? modelKey});
  Future<String> getChatResponseWithContext(List<Map<String, String>> messages, {String? modelKey, String? chatType});
  List<String> getAvailableModels();
  String getModelDisplayName(String modelKey);
  String getCurrentProvider();
  List<String> getAvailableProviders();
  
} 