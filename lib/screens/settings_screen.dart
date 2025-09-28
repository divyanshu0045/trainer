import 'package:fit_ai/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _workoutNotifications = true;
  TimeOfDay _workoutTime = const TimeOfDay(hour: 8, minute: 0);

  bool _mealNotifications = true;
  TimeOfDay _mealTime = const TimeOfDay(hour: 12, minute: 30);

  bool _waterNotifications = true;
  TimeOfDay _waterTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();
    // In a real app, these values would be loaded from user preferences (e.g., SharedPreferences).
  }

  Future<void> _selectTime(BuildContext context, TimeOfDay initialTime,
      Function(TimeOfDay) onTimeChanged) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null && picked != initialTime) {
      onTimeChanged(picked);
    }
  }

  void _scheduleNotifications() {
    final scheduler = ref.read(notificationSchedulerProvider);
    scheduler.cancelAllReminders(); // Clear old reminders first

    if (_workoutNotifications) {
      scheduler.scheduleWorkoutReminder(Time(hour: _workoutTime.hour, minute: _workoutTime.minute));
    }
    if (_mealNotifications) {
      // For simplicity, we schedule a generic "lunch" reminder.
      // A full implementation might schedule reminders for each meal time.
      scheduler.scheduleMealReminder("Lunch", Time(hour: _mealTime.hour, minute: _mealTime.minute));
    }
    if (_waterNotifications) {
      scheduler.scheduleWaterReminder(Time(hour: _waterTime.hour, minute: _waterTime.minute));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _scheduleNotifications,
            tooltip: 'Save Settings',
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('Notification Settings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildNotificationSwitch(
            title: 'Workout Reminders',
            value: _workoutNotifications,
            onChanged: (val) => setState(() => _workoutNotifications = val),
            time: _workoutTime,
            onTimeTap: () => _selectTime(context, _workoutTime, (newTime) {
              setState(() => _workoutTime = newTime);
            }),
          ),
          _buildNotificationSwitch(
            title: 'Meal Reminders',
            value: _mealNotifications,
            onChanged: (val) => setState(() => _mealNotifications = val),
            time: _mealTime,
            onTimeTap: () => _selectTime(context, _mealTime, (newTime) {
              setState(() => _mealTime = newTime);
            }),
          ),
          _buildNotificationSwitch(
            title: 'Water Reminders',
            value: _waterNotifications,
            onChanged: (val) => setState(() => _waterNotifications = val),
            time: _waterTime,
            onTimeTap: () => _selectTime(context, _waterTime, (newTime) {
              setState(() => _waterTime = newTime);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required TimeOfDay time,
    required VoidCallback onTimeTap,
  }) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
        secondary: TextButton(
          onPressed: value ? onTimeTap : null,
          child: Text(
            time.format(context),
            style: TextStyle(
              color: value
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}