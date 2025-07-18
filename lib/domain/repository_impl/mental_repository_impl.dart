import 'package:mind_flow/core/mixins/repository_error_handling.dart';
import 'package:mind_flow/data/datasources/remote_datasource.dart';
import 'package:mind_flow/data/models/mental_analysis_model.dart';
import 'package:mind_flow/domain/repositories/mental_repository.dart';

class MentalRepositoryImpl with RepositoryHandling implements MentalRepository {
  final RemoteDataSource _dataSource;

  MentalRepositoryImpl(this._dataSource);
  @override
  Future<MentalAnalysisModel> analyzeMentality(String userText) {
    return handleRepositoryOperation(operation: () => _dataSource.analyzeMentality(userText));
  }
}