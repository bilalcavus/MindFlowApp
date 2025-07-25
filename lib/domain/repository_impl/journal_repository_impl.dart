import 'package:mind_flow/core/mixins/repository_error_handling.dart';
import 'package:mind_flow/data/datasources/remote_datasource.dart';
import 'package:mind_flow/data/models/emotion_analysis_model.dart';
import 'package:mind_flow/domain/repositories/journal_repository.dart';

class JournalRepositoryImpl with RepositoryHandling implements JournalRepository {
  final RemoteDataSource _remoteDataSource;

  JournalRepositoryImpl(this._remoteDataSource);

  @override
  Future<EmotionAnalysisModel> analyzeEmotion(String userText, String modelKey, {bool isPremiumUser = false}) {
    return handleRepositoryOperation(
      operation: () => _remoteDataSource.analyzeEmotion(userText, modelKey: modelKey, isPremiumUser: isPremiumUser),
      errorMessage: 'Failed to analyze emotion',
    );
  }
}