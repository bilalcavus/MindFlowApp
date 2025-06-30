

import 'package:mind_flow/core/error/error_handler.dart';

abstract class BaseRepository {
  Future<T> handleRepositoryOperation<T>({
    required Future<T> Function() operation,
    String? errorMessage,
  }) async {
    try {
      return await operation();
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: errorMessage ?? 'Repository operation failed',
        type: ErrorType.unknown,
        originalError: e,
      );
    }
  }

  // Future<T?> getCachedData<T>({
  //   required String cacheKey,
  //   required Future<T?> Function() fetchFromSource,
  //   Duration? cacheDuration,
  // });

  // Future<void> clearCache(String key);
} 