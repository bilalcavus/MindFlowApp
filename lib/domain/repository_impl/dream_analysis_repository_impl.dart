import 'package:mind_flow/core/mixins/repository_error_handling.dart';
import 'package:mind_flow/data/datasources/remote_datasource.dart';
import 'package:mind_flow/data/models/dream_analysis_model.dart';
import 'package:mind_flow/domain/repositories/dream_analysis_repository.dart';

class DreamAnalysisRepositoryImpl with RepositoryErrorHandling implements DreamAnalysisRepository {
  final RemoteDataSource _remoteDataSource;

  DreamAnalysisRepositoryImpl(this._remoteDataSource);

  @override
  Future<DreamAnalysisModel> analyzeDream(String userText, String modelKey) {
    return handleRepositoryOperation(
      operation: () => _remoteDataSource.analyzeDream(userText, modelKey: modelKey),
      errorMessage: 'Failed to analyze dream',
    );
  }
}