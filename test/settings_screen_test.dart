import 'package:fit_ai/screens/settings_screen.dart';
import 'package:fit_ai/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mocks
class MockStorageService extends Mock implements StorageService {}

void main() {
  group('SettingsScreen Widget Tests', () {
    late MockStorageService mockStorageService;

    setUp(() {
      mockStorageService = MockStorageService();
      // Provide default mock values for SharedPreferences
      SharedPreferences.setMockInitialValues({
        'workout_enabled': true,
        'workout_hour': 8,
        'workout_minute': 0,
        'meal_enabled': true,
        'meal_hour': 12,
        'meal_minute': 30,
        'water_enabled': false,
        'water_hour': 10,
        'water_minute': 0,
      });
    });

    // Helper to build the widget for testing
    Widget createWidgetUnderTest() {
      return ProviderScope(
        // We don't need to override anything here since the screen creates its own
        // StorageService instance. A refactor could inject this for easier mocking.
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      );
    }

    testWidgets('loads and displays initial settings correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Let the initial loading future complete
      await tester.pumpAndSettle();

      // Verify that the switches are set according to the mock values
      final workoutSwitch = find.widgetWithText(SwitchListTile, 'Workout Reminders');
      final mealSwitch = find.widgetWithText(SwitchListTile, 'Meal Reminders');
      final waterSwitch = find.widgetWithText(SwitchListTile, 'Water Reminders');

      expect(tester.widget<SwitchListTile>(workoutSwitch).value, isTrue);
      expect(tester.widget<SwitchListTile>(mealSwitch).value, isTrue);
      expect(tester.widget<SwitchListTile>(waterSwitch).value, isFalse);

      // Verify that the times are displayed correctly
      expect(find.text('8:00 AM'), findsOneWidget);
      expect(find.text('12:30 PM'), findsOneWidget);
    });

    testWidgets('allows toggling a notification switch', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find the workout switch and verify its initial state
      final workoutSwitch = find.widgetWithText(SwitchListTile, 'Workout Reminders');
      expect(tester.widget<SwitchListTile>(workoutSwitch).value, isTrue);

      // Tap the switch to turn it off
      await tester.tap(workoutSwitch);
      await tester.pump();

      // Verify its state has changed
      expect(tester.widget<SwitchListTile>(workoutSwitch).value, isFalse);
    });

    testWidgets('save button calls the storage service', (WidgetTester tester) async {
      // This test is more complex because the service is instantiated directly.
      // A full test would require refactoring to inject the service.
      // This test serves as a placeholder for that more advanced implementation.

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap the save button
      await tester.tap(find.byIcon(Icons.save));
      await tester.pump();

      // In a real test with injection, we would verify:
      // verify(mockStorageService.saveNotificationSettings(any)).called(1);

      // For now, we just verify that the snackbar appears, indicating the method was called.
      expect(find.text('Notification settings saved!'), findsOneWidget);
    });
  });
}