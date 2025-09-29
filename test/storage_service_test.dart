import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_ai/services/storage_service.dart';
import 'package:flutter/material.dart';

// Mock SharedPreferences for testing
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('StorageService', () {
    late StorageService storageService;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      // SharedPreferences.setMockInitialValues({}); // Not needed with Mockito
      mockSharedPreferences = MockSharedPreferences();
      storageService = StorageService();

      // We need to mock the static getInstance method.
      // This is a known challenge. The common workaround is to not use a static method directly
      // or to wrap it. For this test, we'll assume a direct instance for simplicity,
      // but a real-world scenario might require a different pattern like dependency injection.
      // Since our service is a simple class, we can test its methods directly
      // if we could inject the SharedPreferences instance.

      // Let's refactor the service slightly to allow for injection for testing.
      // (The user will see the final refactored code, not this intermediate thought process)
    });

    // Note: Testing code that uses static methods like `SharedPreferences.getInstance()`
    // can be tricky. A common approach is to refactor the code to allow for dependency injection.
    // However, for this test, we'll use a simplified setup that demonstrates the intent.
    // The `shared_preferences` package itself provides `setMockInitialValues` for this.

    test('saves and retrieves API key', () async {
      SharedPreferences.setMockInitialValues({'openai_api_key': 'test_key'});

      final apiKey = await storageService.getApiKey();
      expect(apiKey, 'test_key');

      await storageService.saveApiKey('new_key');
      final newApiKey = await storageService.getApiKey();
      expect(newApiKey, 'new_key');
    });

    test('saves and retrieves notification settings', () async {
       SharedPreferences.setMockInitialValues({});

      const workoutTime = TimeOfDay(hour: 9, minute: 0);
      const mealTime = TimeOfDay(hour: 13, minute: 0);
      const waterTime = TimeOfDay(hour: 11, minute: 0);

      await storageService.saveNotificationSettings(
        workoutEnabled: true,
        workoutTime: workoutTime,
        mealEnabled: false,
        mealTime: mealTime,
        waterEnabled: true,
        waterTime: waterTime,
      );

      final settings = await storageService.getNotificationSettings();

      expect(settings['workoutEnabled'], true);
      expect(settings['workoutTime'], workoutTime);
      expect(settings['mealEnabled'], false);
      expect(settings['waterEnabled'], true);
      expect(settings['waterTime'], waterTime);
    });

     test('hasApiKey returns correct value', () async {
      SharedPreferences.setMockInitialValues({});
      var hasKey = await storageService.hasApiKey();
      expect(hasKey, false);

      SharedPreferences.setMockInitialValues({'openai_api_key': 'a_key'});
      hasKey = await storageService.hasApiKey();
      expect(hasKey, true);
    });
  });
}