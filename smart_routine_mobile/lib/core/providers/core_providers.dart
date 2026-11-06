import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

// Storage service provider - overridden in main() with initialized instance
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageServiceProvider must be initialized in main');
});

// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// ApiClient provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiClient(storage);
});
