import 'package:mind_flow/data/models/personality_analysis_model.dart';
import 'package:mind_flow/domain/repositories/personality_repository.dart';

class GetPersonalityAnalysis {
  final PersonalityRepository _repository;

  GetPersonalityAnalysis(this._repository);

  Future<PersonalityAnalysisModel> call(String userText){
    return _repository.analyzePersonality(userText);
  }
}