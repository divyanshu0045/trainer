import 'package:fit_ai/providers/api_key_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_model.dart';
import '../models/meal_model.dart';
import '../models/user_model.dart';
import '../services/ai_service.dart';

// Provider for the AiService instance
final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

// Provider for managing the fitness and diet plans
final planProvider = StateNotifierProvider<PlanNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  // Pass the ref to the Notifier so it can read other providers
  return PlanNotifier(aiService, ref);
});

class PlanNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final AiService _aiService;
  final Ref _ref;

  PlanNotifier(this._aiService, this._ref) : super(const AsyncValue.loading());

  // Generate new workout and meal plans from the live AI service
  Future<void> generatePlans(UserModel user) async {
    state = const AsyncValue.loading();
    try {
      // Read the API key from its provider.
      final apiKey = _ref.read(apiKeyProvider).value;
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API Key not found. Please set it in the app.');
      }

      // Pass the key to the service method.
      final response = await _aiService.generatePersonalizedPlan(
        user: user,
        apiKey: apiKey,
      );

      // --- Parse Workout Plan ---
      final workoutData = response['workoutPlan'];
      if (workoutData == null || workoutData['dailyWorkouts'] is! List) {
        throw Exception("Received invalid workout plan format from AI.");
      }

      final workoutPlan = WorkoutPlan(
        id: 'wp_${DateTime.now().millisecondsSinceEpoch}', // Generated ID
        userId: user.id,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        dailyWorkouts: (workoutData['dailyWorkouts'] as List)
            .map((dw) => DailyWorkout.fromMap(dw as Map<String, dynamic>))
            .toList(),
      );

      // --- Parse Meal Plan ---
      final mealData = response['mealPlan'];
      if (mealData == null || mealData['dailyMeals'] is! List) {
        throw Exception("Received invalid meal plan format from AI.");
      }

      final mealPlan = MealPlan(
        id: 'mp_${DateTime.now().millisecondsSinceEpoch}', // Generated ID
        userId: user.id,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        dailyMeals: (mealData['dailyMeals'] as List)
            .map((dm) => DailyMeal.fromMap(dm as Map<String, dynamic>))
            .toList(),
      );

      state = AsyncValue.data({
        'workoutPlan': workoutPlan,
        'mealPlan': mealPlan,
      });

    } catch (e, st) {
      print('Error in PlanNotifier: $e');
      state = AsyncValue.error(e, st);
    }
  }
}