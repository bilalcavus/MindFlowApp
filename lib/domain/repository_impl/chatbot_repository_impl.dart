import 'package:flutter/material.dart';
import 'package:mind_flow/core/error/error_handler.dart';
import 'package:mind_flow/core/services/api_services.dart';
import 'package:mind_flow/domain/repositories/chat_bot_repository.dart';

class ChatbotRepositoryImpl implements ChatBotRepository {
final ApiServices _apiServices;

  ChatbotRepositoryImpl(this._apiServices);

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
  Future<String> chatResponse(String userMessage, String modelKey) {
    return handleRepositoryOperation(operation: () => _apiServices.getChatResponse(userMessage, modelKey: modelKey));
  }
}