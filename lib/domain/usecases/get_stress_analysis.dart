import 'package:mind_flow/data/models/stress_analysis_model.dart';
import 'package:mind_flow/domain/repositories/stress_repository.dart';

class GetStressAnalysis {
  final StressRepository _repository;

  GetStressAnalysis(this._repository);

  Future<StressAnalysisModel> call(String userText){
    return _repository.analyzeStress(userText);
  }
}