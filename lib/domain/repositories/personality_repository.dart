import 'package:mind_flow/data/models/personality_analysis_model.dart';
import 'package:mind_flow/domain/repositories/base_repository.dart';

abstract class PersonalityRepository extends BaseRepository {
  Future<PersonalityAnalysisModel> analyzePersonality(String userText);
}