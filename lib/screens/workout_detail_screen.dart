import 'package:fit_ai/models/workout_model.dart';
import 'package:fit_ai/widgets/exercise_card.dart';
import 'package:flutter/material.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final DailyWorkout dailyWorkout;

  const WorkoutDetailScreen({super.key, required this.dailyWorkout});

  @override
  _WorkoutDetailScreenState createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late Set<int> _completedExercises;

  @override
  void initState() {
    super.initState();
    // In a real app, completion state would be persisted.
    // For this example, it's just stored in the state of this widget.
    _completedExercises = {};
  }

  void _toggleCompletion(int exerciseIndex) {
    setState(() {
      if (_completedExercises.contains(exerciseIndex)) {
        _completedExercises.remove(exerciseIndex);
      } else {
        _completedExercises.add(exerciseIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dailyWorkout.day),
      ),
      body: ListView.builder(
        itemCount: widget.dailyWorkout.exercises.length,
        itemBuilder: (context, index) {
          final exercise = widget.dailyWorkout.exercises[index];
          final isCompleted = _completedExercises.contains(index);
          return ExerciseCard(
            exercise: exercise,
            isCompleted: isCompleted,
            onToggleCompletion: () => _toggleCompletion(index),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Mark the whole day as complete
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Workout for today marked as complete!')),
            );
            Navigator.pop(context);
          },
          child: const Text('Mark Day as Complete'),
        ),
      ),
    );
  }
}