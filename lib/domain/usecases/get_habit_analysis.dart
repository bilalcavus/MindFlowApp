import 'package:mind_flow/data/models/habit_analysis_model.dart';
import 'package:mind_flow/domain/repositories/habit_repository.dart';

class GetHabitAnalysis {
  final HabitRepository _repository;

  GetHabitAnalysis(this._repository);
  Future<HabitAnalysisModel> call(String userText) {
    return _repository.analyzeHabit(userText);
  }
}