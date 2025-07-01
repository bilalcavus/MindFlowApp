import 'package:mind_flow/data/models/dream_analysis_model.dart';
import 'package:mind_flow/domain/repositories/base_repository.dart';

abstract class DreamAnalysisRepository extends BaseRepository {
    Future<DreamAnalysisModel> analyzeDream(String userText, String modelKey);

}