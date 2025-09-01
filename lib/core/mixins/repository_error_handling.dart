import 'package:flutter/material.dart';
import 'package:mind_flow/core/utility/error/error_handler.dart';

mixin RepositoryHandling {
  Future<T> handleRepositoryOperation<T>({
    required Future<T> Function() operation,
    String? errorMessage,
  }) async {
    try {
      return await operation();
    } on AppError {
      rethrow;
    } catch (e, stackTrace) {
      final appError = AppError(
        message: errorMessage ?? 'Repository operation failed',
        type: ErrorType.unknown,
        originalError: e,
        stackTrace: stackTrace,
      );
      debugPrint('🔴 Repository Error: $appError');
      debugPrint('🔴 Original error: ${appError.originalError}');
      debugPrint('🔴 Stack trace: ${appError.stackTrace}');
      throw appError;
    }
  }
} 