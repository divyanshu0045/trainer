import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

// Provider for the StorageService instance
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// StateNotifierProvider to manage the API key state
final apiKeyProvider = StateNotifierProvider<ApiKeyNotifier, AsyncValue<String?>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ApiKeyNotifier(storageService);
});

class ApiKeyNotifier extends StateNotifier<AsyncValue<String?>> {
  final StorageService _storageService;

  ApiKeyNotifier(this._storageService) : super(const AsyncValue.loading()) {
    _loadApiKey();
  }

  // Load the API key from storage on initialization
  Future<void> _loadApiKey() async {
    try {
      final apiKey = await _storageService.getApiKey();
      state = AsyncValue.data(apiKey);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Save the API key to storage and update the state
  Future<void> saveApiKey(String apiKey) async {
    try {
      await _storageService.saveApiKey(apiKey);
      state = AsyncValue.data(apiKey);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Delete the API key from storage and update the state
  Future<void> deleteApiKey() async {
    try {
      await _storageService.deleteApiKey();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}