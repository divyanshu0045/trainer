import 'dart:convert';
import 'package:fit_ai/models/user_model.dart';
import 'package:http/http.dart' as http;

class AiService {
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  // The API key is now passed as a parameter to each method.
  // This decouples the service from how the key is stored or managed.
  Future<Map<String, dynamic>> generatePersonalizedPlan({
    required UserModel user,
    required String apiKey,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final prompt = _buildPlanGenerationPrompt(user);

    final body = json.encode({
      'model': 'gpt-4-turbo',
      'messages': [
        {'role': 'system', 'content': 'You are a world-class personal trainer and dietician AI. Your task is to generate a personalized 7-day workout and diet plan based on the user\'s profile. Respond ONLY with a valid JSON object. Do not include any introductory text, explanations, or markdown formatting. The JSON object must have two top-level keys: "workoutPlan" and "mealPlan".'},
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.7,
      'response_format': {'type': 'json_object'},
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final content = responseBody['choices'][0]['message']['content'];
        return json.decode(content);
      } else {
        print('OpenAI API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to generate plan from OpenAI.');
      }
    } catch (e) {
      print('Error calling OpenAI API: $e');
      throw Exception('An error occurred while communicating with the AI service.');
    }
  }

  Future<String> getChatResponse({
    required String message,
    required String apiKey,
    List<Map<String, String>>? history,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final messages = [
      {'role': 'system', 'content': 'You are a helpful and motivating fitness and nutrition assistant named FitAI. Provide concise, supportive, and accurate information. Do not generate workout or diet plans, but guide the user on general topics.'},
      if (history != null) ...history,
      {'role': 'user', 'content': message},
    ];

    final body = json.encode({
      'model': 'gpt-4-turbo',
      'messages': messages,
      'temperature': 0.5,
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get chat response from OpenAI.');
      }
    } catch (e) {
      throw Exception('An error occurred while communicating with the AI service.');
    }
  }

  String _buildPlanGenerationPrompt(UserModel user) {
    return '''
    Generate a 7-day personalized workout and diet plan based on the following user profile.

    **User Profile:**
    - Age: ${user.age}
    - Gender: ${user.gender}
    - Height: ${user.height} cm
    - Weight: ${user.weight} kg
    - Goal: ${user.fitnessGoal}
    - Activity Level: ${user.activityLevel}
    - Dietary Preference: ${user.dietaryPreferences}
    - Health Conditions/Restrictions: ${user.healthConditions.join(', ').isEmpty ? 'None' : user.healthConditions.join(', ')}

    **JSON Structure Requirements:**

    The JSON response must contain two top-level keys: "workoutPlan" and "mealPlan".

    1.  **workoutPlan**:
        - Should contain a list of "dailyWorkouts".
        - Each object in "dailyWorkouts" must have:
            - "day": String (e.g., "Monday")
            - "exercises": A list of exercise objects.
            - Each exercise object must have:
                - "name": String
                - "sets": String (e.g., "3")
                - "reps": String (e.g., "10-12" or "60s")
                - "rest": String (e.g., "60s")

    2.  **mealPlan**:
        - Should contain a list of "dailyMeals".
        - Each object in "dailyMeals" must have:
            - "day": String (e.g., "Monday")
            - "totalCalories": Integer
            - "meals": A list of meal objects.
            - Each meal object must have:
                - "name": String (e.g., "Breakfast")
                - "time": String (e.g., "8:00 AM")
                - "ingredients": String
                - "calories": Integer

    Please generate a balanced and realistic 3-day workout plan (e.g., Monday, Wednesday, Friday) and a 2-day sample meal plan to demonstrate the structure. Ensure the total calories are appropriate for the user's goal.
    ''';
  }
}