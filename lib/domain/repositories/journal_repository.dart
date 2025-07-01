import 'package:mind_flow/data/models/emotion_analysis_model.dart';
import 'package:mind_flow/domain/repositories/base_repository.dart';

abstract class JournalRepository extends BaseRepository{
  
  Future<EmotionAnalysisModel> analyzeEmotion(String userText, String modelkey);
  
}