import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

enum ErrorType {
  network,
  server,
  authentication,
  validation,
  unknown
}

class AppError {
  final String message;
  final ErrorType type;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppError({
    required this.message,
    required this.type,
    this.originalError,
    this.stackTrace,
  });

  factory AppError.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError(
          message: 'Bağlantı zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin.',
          type: ErrorType.network,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return AppError(
            message: 'Oturum süreniz dolmuş olabilir. Lütfen tekrar giriş yapın.',
            type: ErrorType.authentication,
            originalError: error,
            stackTrace: error.stackTrace,
          );
        }
        return AppError(
          message: 'Sunucu hatası: ${error.response?.statusCode}',
          type: ErrorType.server,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      case DioExceptionType.cancel:
        return AppError(
          message: 'İstek iptal edildi.',
          type: ErrorType.unknown,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      default:
        return AppError(
          message: 'Bir hata oluştu. Lütfen daha sonra tekrar deneyin.',
          type: ErrorType.unknown,
          originalError: error,
          stackTrace: error.stackTrace,
        );
    }
  }

  factory AppError.fromException(dynamic error) {
    if (error is AppError) return error;
    return AppError(
      message: 'Beklenmeyen bir hata oluştu.',
      type: ErrorType.unknown,
      originalError: error,
    );
  }
}

class ErrorHandler {
  static void handleError(BuildContext context, dynamic error) {
    final appError = error is AppError ? error : AppError.fromException(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appError.message),
        backgroundColor: _getErrorColor(appError.type),
        duration: const Duration(seconds: 3),
      ),
    );

    _logError(appError);
    _handleSpecialCases(context, appError);
  }

  static void handleSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.server:
        return Colors.red;
      case ErrorType.authentication:
        return Colors.deepPurpleAccent;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.unknown:
        return Colors.grey;
    }
  }

  static void _logError(AppError error) {
    print('Error: ${error.message}');
    print('Type: ${error.type}');
    if (error.stackTrace != null) {
      print('Stack trace: ${error.stackTrace}');
    }
  }

  static void _handleSpecialCases(BuildContext context, AppError error) {
    switch (error.type) {
      case ErrorType.authentication:
        break;
      case ErrorType.network:
        break;
      default:
        break;
    }
  }
} 