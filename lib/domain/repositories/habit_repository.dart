import 'package:mind_flow/data/models/habit_analysis_model.dart';
import 'package:mind_flow/domain/repositories/base_repository.dart';

abstract class HabitRepository extends BaseRepository {
  Future<HabitAnalysisModel> analyzeHabit(String userText, {bool isPremiumUser = false});
}