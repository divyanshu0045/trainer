import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // --- API Key ---
  static const String _apiKeyKey = 'openai_api_key';

  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
  }

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  Future<bool> hasApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_apiKeyKey);
  }

  Future<void> deleteApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyKey);
  }

  // --- Notification Settings ---
  static const String _workoutEnabledKey = 'workout_enabled';
  static const String _workoutHourKey = 'workout_hour';
  static const String _workoutMinuteKey = 'workout_minute';

  static const String _mealEnabledKey = 'meal_enabled';
  static const String _mealHourKey = 'meal_hour';
  static const String _mealMinuteKey = 'meal_minute';

  static const String _waterEnabledKey = 'water_enabled';
  static const String _waterHourKey = 'water_hour';
  static const String _waterMinuteKey = 'water_minute';

  // Save all notification settings at once
  Future<void> saveNotificationSettings({
    required bool workoutEnabled,
    required TimeOfDay workoutTime,
    required bool mealEnabled,
    required TimeOfDay mealTime,
    required bool waterEnabled,
    required TimeOfDay waterTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_workoutEnabledKey, workoutEnabled);
    await prefs.setInt(_workoutHourKey, workoutTime.hour);
    await prefs.setInt(_workoutMinuteKey, workoutTime.minute);

    await prefs.setBool(_mealEnabledKey, mealEnabled);
    await prefs.setInt(_mealHourKey, mealTime.hour);
    await prefs.setInt(_mealMinuteKey, mealTime.minute);

    await prefs.setBool(_waterEnabledKey, waterEnabled);
    await prefs.setInt(_waterHourKey, waterTime.hour);
    await prefs.setInt(_waterMinuteKey, waterTime.minute);
  }

  // Load all notification settings
  Future<Map<String, dynamic>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'workoutEnabled': prefs.getBool(_workoutEnabledKey) ?? true,
      'workoutTime': TimeOfDay(
        hour: prefs.getInt(_workoutHourKey) ?? 8, // Default 8:00 AM
        minute: prefs.getInt(_workoutMinuteKey) ?? 0,
      ),
      'mealEnabled': prefs.getBool(_mealEnabledKey) ?? true,
      'mealTime': TimeOfDay(
        hour: prefs.getInt(_mealHourKey) ?? 12, // Default 12:30 PM
        minute: prefs.getInt(_mealMinuteKey) ?? 30,
      ),
      'waterEnabled': prefs.getBool(_waterEnabledKey) ?? true,
      'waterTime': TimeOfDay(
        hour: prefs.getInt(_waterHourKey) ?? 10, // Default 10:00 AM
        minute: prefs.getInt(_waterMinuteKey) ?? 0,
      ),
    };
  }
}