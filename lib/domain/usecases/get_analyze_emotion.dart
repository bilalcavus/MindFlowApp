import 'package:mind_flow/data/models/emotion_analysis_model.dart';
import 'package:mind_flow/domain/repositories/journal_repository.dart';

class GetAnalyzeEmotion {
  final JournalRepository repository;

  GetAnalyzeEmotion(this.repository);

  Future<EmotionAnalysisModel> call(String userText, String modelKey, {bool isPremiumUser = false}) {
    return repository.analyzeEmotion(userText, modelKey, isPremiumUser: isPremiumUser);
  }
}