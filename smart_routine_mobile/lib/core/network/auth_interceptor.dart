import 'package:dio/dio.dart';
import '../services/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storageService;
  final void Function()? onUnauthorized;

  AuthInterceptor(this._storageService, {this.onUnauthorized});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _storageService.clearSession();
      onUnauthorized?.call();
    }
    return handler.next(err);
  }
}
