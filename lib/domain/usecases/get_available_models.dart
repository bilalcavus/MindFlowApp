import 'package:mind_flow/data/datasources/remote_datasource.dart';

class GetAvailableModels {
  final RemoteDataSource _remoteDataSource;

  GetAvailableModels(this._remoteDataSource);

  List<String> call() {
    return _remoteDataSource.getAvailableModels();
  }
} 