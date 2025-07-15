import 'package:mind_flow/data/datasources/remote_datasource.dart';

class GetModelDisplayName {
  final RemoteDataSource _remoteDataSource;

  GetModelDisplayName(this._remoteDataSource);

  String call(String modelKey) {
    return _remoteDataSource.getModelDisplayName(modelKey);
  }
} 