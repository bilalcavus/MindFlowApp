import 'package:dio/dio.dart';
import 'package:mind_flow/core/constants/api_constants.dart';

class DioHelper {
  //DIO INTERCEPTER
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.openAIBaseURL,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Authorization': 'Bearer ${ApiConstants.openAIKey}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<dynamic> dioGet(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      Response response = await _dio.get(endpoint, queryParameters: queryParams);
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<dynamic> dioPost(String endpoint, dynamic data) async {
    try {
      Response response = await _dio.post(endpoint, data: data, options: Options(validateStatus: (status) {
        return status != null && status < 500;
      }));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        return {'error': 'API yanıt kodu: ${response.statusCode}', 'message': response.data.toString(), 'statusCode': response.statusCode};
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
        } else if (e.type == DioExceptionType.connectionError) {}
      }
      return _handleError(e);
    }
  }

  Future<dynamic> dioPut(String endpoint, dynamic data) async {
    try {
      Response response = await _dio.put(endpoint, data: data, options: Options(validateStatus: (status) {
        return status != null && status < 500;
      }));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        return {'error': 'API yanıt kodu: ${response.statusCode}', 'message': response.data.toString(), 'statusCode': response.statusCode};
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
        }
      }
      return _handleError(e);
    }
  }

  Future<dynamic> dioDelete(String endpoint) async {
    try {
      Response response = await _dio.delete(endpoint);
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  dynamic _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return {'error': 'Bağlantı zaman aşımına uğradı'};
        case DioExceptionType.receiveTimeout:
          return {'error': 'Yanıt zaman aşımına uğradı'};
        case DioExceptionType.badResponse:
          if (error.response != null) {
            return {'error': 'Hatalı yanıt: ${error.response?.statusCode}', 'message': error.response?.data.toString() ?? 'Bilinmeyen hata', 'statusCode': error.response?.statusCode};
          }
          return {'error': 'Hatalı yanıt: ${error.response?.statusCode}'};
        case DioExceptionType.cancel:
          return {'error': 'İstek iptal edildi'};
        case DioExceptionType.connectionError:
          return {'error': 'Bağlantı hatası'};
        case DioExceptionType.unknown:
          if (error.error != null) {
            return {'error': 'Hata: ${error.error.toString()}'};
          }
          return {'error': 'Bilinmeyen bir hata oluştu'};
        default:
          return {'error': 'Bilinmeyen bir hata oluştu'};
      }
    }
    return {'error': 'Bilinmeyen bir hata oluştu: ${error.toString()}'};
  }
}