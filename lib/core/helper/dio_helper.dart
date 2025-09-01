import 'package:dio/dio.dart';
import 'package:mind_flow/core/utility/constants/api_constants.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioHelper {
  late Dio _dio;
  
  String _currentProvider = ApiConstants.defaultProvider;

  DioHelper({String? provider}) {
    _currentProvider = provider ?? ApiConstants.defaultProvider;
    _initializeDio();
  }

  void _initializeDio() {
    final baseUrl = ApiConstants.getBaseUrl(_currentProvider);
    final apiKey = ApiConstants.getApiKey(_currentProvider);

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    // _dio.interceptors.add(
    //   PrettyDioLogger(
    //     requestHeader: true,
    //     requestBody: true,
    //     responseHeader: true,
    //     responseBody: true,
    //     error: true,
    //     compact: true,
    //     maxWidth: 120,
    //   ),
    // );
  }

  

  void switchProvider(String provider) {
    _currentProvider = provider;
    _initializeDio();
  }

  String get currentProvider => _currentProvider;

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
        final errorData = {
          'error': 'API yanıt kodu: ${response.statusCode}', 
          'message': response.data.toString(), 
          'statusCode': response.statusCode,
          'provider': _currentProvider,
        };
        
        // Check for rate limit errors
        if (response.statusCode == 429 || 
            ApiConstants.isRateLimitError(response.data.toString())) {
          errorData['isRateLimit'] = true;
        }
        
        return errorData;
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
        final errorData = {
          'error': 'API yanıt kodu: ${response.statusCode}', 
          'message': response.data.toString(), 
          'statusCode': response.statusCode,
          'provider': _currentProvider,
        };
        
        // Check for rate limit errors
        if (response.statusCode == 429 || 
            ApiConstants.isRateLimitError(response.data.toString())) {
          errorData['isRateLimit'] = true;
        }
        
        return errorData;
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
    Map<String, dynamic> errorData = {'provider': _currentProvider};
    
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          errorData.addAll({'error': 'Bağlantı zaman aşımına uğradı'});
          break;
        case DioExceptionType.receiveTimeout:
          errorData.addAll({'error': 'Yanıt zaman aşımına uğradı'});
          break;
        case DioExceptionType.badResponse:
          if (error.response != null) {
            final statusCode = error.response?.statusCode;
            final responseData = error.response?.data?.toString() ?? 'Bilinmeyen hata';
            
            errorData.addAll({
              'error': 'Hatalı yanıt: $statusCode', 
              'message': responseData, 
              'statusCode': statusCode
            });
            
            // Check for rate limit errors
            if (statusCode == 429 || ApiConstants.isRateLimitError(responseData)) {
              errorData['isRateLimit'] = true;
            }
          } else {
            errorData.addAll({'error': 'Hatalı yanıt: ${error.response?.statusCode}'});
          }
          break;
        case DioExceptionType.cancel:
          errorData.addAll({'error': 'İstek iptal edildi'});
          break;
        case DioExceptionType.connectionError:
          errorData.addAll({'error': 'Bağlantı hatası'});
          break;
        case DioExceptionType.unknown:
          if (error.error != null) {
            final errorMessage = error.error.toString();
            errorData.addAll({'error': 'Hata: $errorMessage'});
            
            // Check for rate limit errors in unknown errors too
            if (ApiConstants.isRateLimitError(errorMessage)) {
              errorData['isRateLimit'] = true;
            }
          } else {
            errorData.addAll({'error': 'Bilinmeyen bir hata oluştu'});
          }
          break;
        default:
          errorData.addAll({'error': 'Bilinmeyen bir hata oluştu'});
          break;
      }
    } else {
      final errorMessage = error.toString();
      errorData.addAll({'error': 'Bilinmeyen bir hata oluştu: $errorMessage'});
      
      // Check for rate limit errors
      if (ApiConstants.isRateLimitError(errorMessage)) {
        errorData['isRateLimit'] = true;
      }
    }
    
    return errorData;
  }
}