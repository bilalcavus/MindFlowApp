import 'package:mind_flow/core/mixins/repository_error_handling.dart';
import 'package:mind_flow/data/datasources/remote_datasource.dart';
import 'package:mind_flow/data/models/stress_analysis_model.dart';
import 'package:mind_flow/domain/repositories/stress_repository.dart';

class StressAnalysisImpl with RepositoryHandling implements StressRepository {
  final RemoteDataSource _dataSource;

  StressAnalysisImpl(this._dataSource);
  
  @override
  Future<StressAnalysisModel> analyzeStress(String userText, {bool isPremiumUser = false}) {
    return handleRepositoryOperation(operation: () => _dataSource.analyzeStress(userText, isPremiumUser: isPremiumUser));
  }
  
}