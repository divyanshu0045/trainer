import 'package:fit_ai/models/meal_model.dart';
import 'package:fit_ai/widgets/meal_card.dart';
import 'package:flutter/material.dart';

class DietDetailScreen extends StatelessWidget {
  final DailyMeal dailyMeal;

  const DietDetailScreen({super.key, required this.dailyMeal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dailyMeal.day),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Calories: ${dailyMeal.totalCalories} kcal',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dailyMeal.meals.length,
              itemBuilder: (context, index) {
                final meal = dailyMeal.meals[index];
                return MealCard(meal: meal);
              },
            ),
          ),
        ],
      ),
    );
  }
}