

import 'package:mind_flow/core/mixins/repository_error_handling.dart';

abstract class BaseRepository with RepositoryErrorHandling {
  // Future<T?> getCachedData<T>({
  //   required String cacheKey,
  //   required Future<T?> Function() fetchFromSource,
  //   Duration? cacheDuration,
  // });

  // Future<void> clearCache(String key);
}