import 'package:flutter/material.dart';
import 'package:mind_flow/core/error/error_handler.dart';
import 'package:mind_flow/core/services/api_services.dart';
import 'package:mind_flow/data/models/emotion_analysis_model.dart';
import 'package:mind_flow/domain/repositories/journal_repository.dart';

class JournalRepositoryImpl implements JournalRepository {
  final ApiServices _apiServices;

  JournalRepositoryImpl(this._apiServices);

   @override
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
    throw appError;
  }
}

  @override
  Future<EmotionAnalysisModel> analyzeEmotion(String userText, String modelKey) {
    return handleRepositoryOperation(operation: () => _apiServices.analyzeEmotion(userText, modelKey: modelKey));
  }

}