import 'package:mind_flow/core/mixins/repository_error_handling.dart';
import 'package:mind_flow/data/datasources/remote_datasource.dart';
import 'package:mind_flow/data/models/personality_analysis_model.dart';
import 'package:mind_flow/domain/repositories/personality_repository.dart';

class PersonalityRepositoryImpl with RepositoryHandling implements PersonalityRepository {
  final RemoteDataSource _dataSource;

  PersonalityRepositoryImpl(this._dataSource);
  @override
  Future<PersonalityAnalysisModel> analyzePersonality(String userText, {bool isPremiumUser = false}) {
    return handleRepositoryOperation(operation: () => _dataSource.analyzePersonality(userText, isPremiumUser: isPremiumUser));
  }
}