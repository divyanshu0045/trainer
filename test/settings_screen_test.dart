import 'package:fit_ai/models/time_model.dart';
import 'package:fit_ai/providers/notification_provider.dart';
import 'package:fit_ai/screens/settings_screen.dart';
import 'package:fit_ai/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_screen_test.mocks.dart';

@GenerateMocks([StorageService, NotificationScheduler])
void main() {
  group('SettingsScreen Widget Tests', () {
    late MockStorageService mockStorageService;
    late MockNotificationScheduler mockNotificationScheduler;

    setUp(() {
      mockStorageService = MockStorageService();
      mockNotificationScheduler = MockNotificationScheduler();

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

      // Mock the getNotificationSettings method
      when(mockStorageService.getNotificationSettings()).thenAnswer((_) async => {
            'workoutEnabled': true,
            'workoutTime': const TimeOfDay(hour: 8, minute: 0),
            'mealEnabled': true,
            'mealTime': const TimeOfDay(hour: 12, minute: 30),
            'waterEnabled': false,
            'waterTime': const TimeOfDay(hour: 10, minute: 0),
          });
    });

    // Helper to build the widget for testing
    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(mockStorageService),
          notificationSchedulerProvider
              .overrideWithValue(mockNotificationScheduler),
        ],
        child: MaterialApp(
          home: SettingsScreen(storageService: mockStorageService),
        ),
      );
    }

    testWidgets('loads and displays initial settings correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final workoutSwitch =
          find.widgetWithText(SwitchListTile, 'Workout Reminders');
      final mealSwitch =
          find.widgetWithText(SwitchListTile, 'Meal Reminders');
      final waterSwitch =
          find.widgetWithText(SwitchListTile, 'Water Reminders');

      expect(tester.widget<SwitchListTile>(workoutSwitch).value, isTrue);
      expect(tester.widget<SwitchListTile>(mealSwitch).value, isTrue);
      expect(tester.widget<SwitchListTile>(waterSwitch).value, isFalse);

      expect(find.text('8:00 AM'), findsOneWidget);
      expect(find.text('12:30 PM'), findsOneWidget);
    });

    testWidgets('allows toggling a notification switch',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final workoutSwitch =
          find.widgetWithText(SwitchListTile, 'Workout Reminders');
      expect(tester.widget<SwitchListTile>(workoutSwitch).value, isTrue);

      await tester.tap(workoutSwitch);
      await tester.pump();

      expect(tester.widget<SwitchListTile>(workoutSwitch).value, isFalse);
    });

    testWidgets('save button calls the storage and notification services',
        (WidgetTester tester) async {
      when(mockStorageService.saveNotificationSettings(
        workoutEnabled: anyNamed('workoutEnabled'),
        workoutTime: anyNamed('workoutTime'),
        mealEnabled: anyNamed('mealEnabled'),
        mealTime: anyNamed('mealTime'),
        waterEnabled: anyNamed('waterEnabled'),
        waterTime: anyNamed('waterTime'),
      )).thenAnswer((_) async {});
      when(mockNotificationScheduler.cancelAllReminders())
          .thenAnswer((_) async {});
      when(mockNotificationScheduler.scheduleWorkoutReminder(any))
          .thenAnswer((_) async {});
      when(mockNotificationScheduler.scheduleMealReminder(any, any))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      verify(mockStorageService.saveNotificationSettings(
        workoutEnabled: true,
        workoutTime: const TimeOfDay(hour: 8, minute: 0),
        mealEnabled: true,
        mealTime: const TimeOfDay(hour: 12, minute: 30),
        waterEnabled: false,
        waterTime: const TimeOfDay(hour: 10, minute: 0),
      )).called(1);

      verify(mockNotificationScheduler.cancelAllReminders()).called(1);
      verify(mockNotificationScheduler.scheduleWorkoutReminder(any)).called(1);
      verify(mockNotificationScheduler.scheduleMealReminder(any, any))
          .called(1);
      verifyNever(mockNotificationScheduler.scheduleWaterReminder(any));

      expect(find.text('Notification settings saved!'), findsOneWidget);
    });
  });
}