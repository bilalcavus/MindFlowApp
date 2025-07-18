import 'package:mind_flow/data/models/mental_analysis_model.dart';
import 'package:mind_flow/domain/repositories/mental_repository.dart';

class GetMentalAnalysis {
  final MentalRepository _repository;

  GetMentalAnalysis(this._repository);

  Future<MentalAnalysisModel> call(String userText){
    return _repository.analyzeMentality(userText);
  }
}