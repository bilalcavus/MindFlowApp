import 'package:mind_flow/data/models/mental_analysis_model.dart';
import 'package:mind_flow/domain/repositories/base_repository.dart';

abstract class MentalRepository extends BaseRepository {
  Future<MentalAnalysisModel> analyzeMentality(String userText);
}