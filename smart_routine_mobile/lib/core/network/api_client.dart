import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../errors/api_exception.dart';
import '../services/storage_service.dart';
import 'auth_interceptor.dart';

class ApiClient {
  late final Dio _dio;
  final StorageService _storageService;

  ApiClient(this._storageService, {void Function()? onUnauthorized}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
      ),
    );

    _dio.interceptors.add(
      AuthInterceptor(_storageService, onUnauthorized: onUnauthorized),
    );
  }

  void updateBaseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  dynamic _handleResponse(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('success')) {
      if (data['success'] == true) {
        return data['data'];
      } else {
        throw ApiException(
          message: data['error'] ?? 'API request unsuccessful',
          statusCode: response.statusCode,
          details: data,
        );
      }
    }
    return data;
  }
}
