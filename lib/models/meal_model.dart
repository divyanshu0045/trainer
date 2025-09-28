import 'package:cloud_firestore/cloud_firestore.dart';

class MealPlan {
  final String id;
  final String userId;
  final List<DailyMeal> dailyMeals;
  final DateTime startDate;
  final DateTime endDate;

  MealPlan({
    required this.id,
    required this.userId,
    required this.dailyMeals,
    required this.startDate,
    required this.endDate,
  });

  factory MealPlan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MealPlan(
      id: doc.id,
      userId: data['userId'],
      dailyMeals: (data['dailyMeals'] as List<dynamic>)
          .map((e) => DailyMeal.fromMap(e))
          .toList(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'dailyMeals': dailyMeals.map((e) => e.toMap()).toList(),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }
}

class DailyMeal {
  final String day;
  final List<Meal> meals;
  final int totalCalories;

  DailyMeal({
    required this.day,
    required this.meals,
    required this.totalCalories,
  });

  factory DailyMeal.fromMap(Map<String, dynamic> map) {
    return DailyMeal(
      day: map['day'],
      meals: (map['meals'] as List<dynamic>).map((e) => Meal.fromMap(e)).toList(),
      totalCalories: map['totalCalories'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'meals': meals.map((e) => e.toMap()).toList(),
      'totalCalories': totalCalories,
    };
  }
}

class Meal {
  final String name;
  final String time;
  final String ingredients;
  final int calories;
  final String? instructions;

  Meal({
    required this.name,
    required this.time,
    required this.ingredients,
    required this.calories,
    this.instructions,
  });

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      name: map['name'],
      time: map['time'],
      ingredients: map['ingredients'],
      calories: map['calories'],
      instructions: map['instructions'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'time': time,
      'ingredients': ingredients,
      'calories': calories,
      'instructions': instructions,
    };
  }
}