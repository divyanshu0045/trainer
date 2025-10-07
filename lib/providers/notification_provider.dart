import 'package:fit_ai/models/time_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' hide Time;
import '../services/notification_service.dart';

// Provider for the NotificationService instance
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Provider to initialize the notification service
final initializeNotificationProvider = FutureProvider<void>((ref) async {
  await ref.watch(notificationServiceProvider).init();
});

// A simple provider to expose scheduling methods to the UI.
// This could be expanded into a StateNotifier for more complex state.
final notificationSchedulerProvider = Provider((ref) {
  final notificationService = ref.watch(notificationServiceProvider);

  return NotificationScheduler(notificationService);
});

class NotificationScheduler {
  final NotificationService _notificationService;

  NotificationScheduler(this._notificationService);

  // Schedule a workout reminder
  Future<void> scheduleWorkoutReminder(Time time) {
    return _notificationService.scheduleDailyNotification(
      id: 0,
      title: 'Workout Time!',
      body: 'Time to get moving! Open FitAI to see your workout for today.',
      time: time,
    );
  }

  // Schedule a meal reminder
  Future<void> scheduleMealReminder(String mealName, Time time) {
    return _notificationService.scheduleDailyNotification(
      id: 1, // Use a different ID for each notification type
      title: 'Meal Time: $mealName',
      body: 'Time to eat! Check your meal plan in FitAI.',
      time: time,
    );
  }

  // Schedule a water reminder
  Future<void> scheduleWaterReminder(Time time) {
    return _notificationService.scheduleDailyNotification(
      id: 2,
      title: 'Stay Hydrated!',
      body: 'Time to drink some water.',
      time: time,
    );
  }

  // Cancel all reminders
  Future<void> cancelAllReminders() {
    return _notificationService.cancelAllNotifications();
  }
}