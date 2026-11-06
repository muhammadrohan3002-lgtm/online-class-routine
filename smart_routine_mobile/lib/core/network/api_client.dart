import 'dart:convert';
import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../errors/api_exception.dart';
import '../services/storage_service.dart';
import 'auth_interceptor.dart';

class ApiClient {
  late final Dio _dio;
  final StorageService _storageService;
  bool _isProbing = false;

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

  bool _isConnectionError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout;
  }

  Future<bool> _tryAutoDiscoverWorkingHost() async {
    if (_isProbing) return false;
    _isProbing = true;

    try {
      for (final candidate in ApiEndpoints.candidateUrls) {
        if (candidate == _dio.options.baseUrl) continue;
        try {
          final probeDio = Dio(
            BaseOptions(
              baseUrl: candidate,
              connectTimeout: const Duration(milliseconds: 2500),
              receiveTimeout: const Duration(milliseconds: 2500),
            ),
          );
          final res = await probeDio.get(ApiEndpoints.health);
          if (res.statusCode == 200) {
            updateBaseUrl(candidate);
            ApiEndpoints.baseUrl = candidate;
            await _storageService.setBaseUrl(candidate);
            return true;
          }
        } catch (_) {
          // Probe next candidate
        }
      }
    } finally {
      _isProbing = false;
    }
    return false;
  }

  Future<dynamic> _executeWithAutoDiscovery(
    Future<Response> Function() requestFn,
  ) async {
    try {
      final response = await requestFn();
      return _handleResponse(response);
    } on DioException catch (e) {
      if (_isConnectionError(e)) {
        final switched = await _tryAutoDiscoverWorkingHost();
        if (switched) {
          try {
            final retryResponse = await requestFn();
            return _handleResponse(retryResponse);
          } on DioException catch (retryError) {
            throw ApiException.fromDioError(retryError);
          }
        }
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _executeWithAutoDiscovery(
      () => _dio.get(path, queryParameters: queryParameters),
    );
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _executeWithAutoDiscovery(
      () => _dio.post(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _executeWithAutoDiscovery(
      () => _dio.put(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _executeWithAutoDiscovery(
      () => _dio.delete(path, queryParameters: queryParameters),
    );
  }

  dynamic _handleResponse(Response response) {
    dynamic data = response.data;
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {}
    }

    if (data is Map && data.containsKey('success')) {
      if (data['success'] == true) {
        return data['data'];
      } else {
        throw ApiException(
          message: data['error']?.toString() ?? 'API request unsuccessful',
          statusCode: response.statusCode,
          details: data,
        );
      }
    }
    return data;
  }
}
