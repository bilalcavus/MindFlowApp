import 'package:mind_flow/data/models/dream_analysis_model.dart';
import 'package:mind_flow/domain/repositories/dream_analysis_repository.dart';


class GetDreamAnalysis {
  final DreamAnalysisRepository repository;

  GetDreamAnalysis(this.repository);

  Future<DreamAnalysisModel> call(String userText, String modelKey, {bool isPremiumUser = false}) {
    return repository.analyzeDream(userText, modelKey, isPremiumUser: isPremiumUser);
  }
  
}