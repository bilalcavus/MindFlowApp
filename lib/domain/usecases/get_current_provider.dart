import 'package:mind_flow/data/datasources/remote_datasource.dart';

class GetCurrentProvider {
  final RemoteDataSource _remoteDataSource;

  GetCurrentProvider(this._remoteDataSource);

  String call() {
    return _remoteDataSource.getCurrentProvider();
  }
} 