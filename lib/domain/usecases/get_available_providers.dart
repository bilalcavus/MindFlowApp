import 'package:mind_flow/data/datasources/remote_datasource.dart';

class GetAvailableProviders {
  final RemoteDataSource _remoteDataSource;

  GetAvailableProviders(this._remoteDataSource);

  List<String> call() {
    return _remoteDataSource.getAvailableProviders();
  }
} 