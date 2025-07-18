import 'package:mind_flow/data/models/stress_analysis_model.dart';
import 'package:mind_flow/domain/repositories/base_repository.dart';

abstract class StressRepository extends BaseRepository {
  Future<StressAnalysisModel> analyzeStress(String userText);
}