import 'package:flutter/material.dart';

// App-wide constants
const String appName = 'FitAI';

// API Keys are managed via the .env file and loaded by flutter_dotenv.

// Firestore Collection Names
const String usersCollection = 'users';
const String workoutPlansCollection = 'workoutPlans';
const String mealPlansCollection = 'mealPlans';
const String feedbackCollection = 'feedback';

// Colors for UI
class AppColors {
  static const Color primaryColor = Color(0xFF4A90E2);
  static const Color accentColor = Color(0xFF50E3C2);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF333333);
  static const Color cardColor = Colors.white;
}

// Text Styles
class AppTextStyles {
  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textColor,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
}