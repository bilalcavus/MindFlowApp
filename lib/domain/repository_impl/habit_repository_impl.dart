import 'package:mind_flow/core/mixins/repository_error_handling.dart';
import 'package:mind_flow/data/datasources/remote_datasource.dart';
import 'package:mind_flow/data/models/habit_analysis_model.dart';
import 'package:mind_flow/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl with RepositoryHandling implements HabitRepository {
  final RemoteDataSource _dataSource;

  HabitRepositoryImpl(this._dataSource);

  @override
  Future<HabitAnalysisModel> analyzeHabit(String userText) {
    return handleRepositoryOperation(operation: () => _dataSource.analyzeHabit(userText));
  }
}