import 'package:flutter/material.dart';
import 'package:mind_flow/core/error/error_handler.dart';
import 'package:mind_flow/core/services/api_services.dart';
import 'package:mind_flow/data/models/dream_analysis_model.dart';
import 'package:mind_flow/domain/repositories/dream_analysis_repository.dart';

class DreamAnalysisRepositoryImpl implements DreamAnalysisRepository {
    final ApiServices _apiServices;

    DreamAnalysisRepositoryImpl(this._apiServices);
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
    debugPrint('🔴 Original error: ${appError.originalError}');
    debugPrint('🔴 Stack trace: ${appError.stackTrace}');
    throw appError;
  }
}
  @override
  Future<DreamAnalysisModel> analyzeDream(String userText, String modelKey) {
    return handleRepositoryOperation(operation:() => _apiServices.analyzeDream(userText, modelKey: modelKey));
  }


  
}