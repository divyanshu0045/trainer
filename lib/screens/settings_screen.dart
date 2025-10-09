import 'package:fit_ai/models/time_model.dart';
import 'package:fit_ai/providers/notification_provider.dart';
import 'package:fit_ai/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final StorageService _storageService = StorageService();
  bool _isLoading = true;

  // Default values
  bool _workoutNotifications = true;
  TimeOfDay _workoutTime = const TimeOfDay(hour: 8, minute: 0);

  bool _mealNotifications = true;
  TimeOfDay _mealTime = const TimeOfDay(hour: 12, minute: 30);

  bool _waterNotifications = true;
  TimeOfDay _waterTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _storageService.getNotificationSettings();
    setState(() {
      _workoutNotifications = settings['workoutEnabled'];
      _workoutTime = settings['workoutTime'];
      _mealNotifications = settings['mealEnabled'];
      _mealTime = settings['mealTime'];
      _waterNotifications = settings['waterEnabled'];
      _waterTime = settings['waterTime'];
      _isLoading = false;
    });
  }

  Future<void> _selectTime(BuildContext context, TimeOfDay initialTime,
      Function(TimeOfDay) onTimeChanged) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null && picked != initialTime) {
      setState(() {
        onTimeChanged(picked);
      });
    }
  }

  Future<void> _saveAndScheduleNotifications() async {
    // Save settings to local storage
    await _storageService.saveNotificationSettings(
      workoutEnabled: _workoutNotifications,
      workoutTime: _workoutTime,
      mealEnabled: _mealNotifications,
      mealTime: _mealTime,
      waterEnabled: _waterNotifications,
      waterTime: _waterTime,
    );

    // Schedule the notifications based on the new settings
    final scheduler = ref.read(notificationSchedulerProvider);
    scheduler.cancelAllReminders(); // Clear old reminders first

    if (_workoutNotifications) {
      scheduler.scheduleWorkoutReminder(Time(hour: _workoutTime.hour, minute: _workoutTime.minute));
    }
    if (_mealNotifications) {
      scheduler.scheduleMealReminder("Lunch", Time(hour: _mealTime.hour, minute: _mealTime.minute));
    }
    if (_waterNotifications) {
      scheduler.scheduleWaterReminder(Time(hour: _waterTime.hour, minute: _waterTime.minute));
    }

    if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification settings saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAndScheduleNotifications,
            tooltip: 'Save Settings',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                    _workoutTime = newTime;
                  }),
                ),
                _buildNotificationSwitch(
                  title: 'Meal Reminders',
                  value: _mealNotifications,
                  onChanged: (val) => setState(() => _mealNotifications = val),
                  time: _mealTime,
                  onTimeTap: () => _selectTime(context, _mealTime, (newTime) {
                    _mealTime = newTime;
                  }),
                ),
                _buildNotificationSwitch(
                  title: 'Water Reminders',
                  value: _waterNotifications,
                  onChanged: (val) => setState(() => _waterNotifications = val),
                  time: _waterTime,
                  onTimeTap: () => _selectTime(context, _waterTime, (newTime) {
                    _waterTime = newTime;
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
              color: value ? Theme.of(context).colorScheme.primary : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}