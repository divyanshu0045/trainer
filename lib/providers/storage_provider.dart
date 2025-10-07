import 'package:fit_ai/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the StorageService instance
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});