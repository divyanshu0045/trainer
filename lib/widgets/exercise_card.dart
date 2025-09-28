import 'package:fit_ai/models/workout_model.dart';
import 'package:fit_ai/screens/video_player_screen.dart';
import 'package:flutter/material.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final bool isCompleted;
  final VoidCallback onToggleCompletion;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.isCompleted,
    required this.onToggleCompletion,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? Theme.of(context).colorScheme.primary : Colors.grey,
          size: 30,
        ),
        title: Text(
          exercise.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
        ),
        subtitle: Text(
          '${exercise.sets} sets, ${exercise.reps} reps, ${exercise.rest} rest',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        onTap: onToggleCompletion,
        trailing: exercise.videoUrl != null
            ? IconButton(
                icon: const Icon(Icons.play_circle_fill),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VideoPlayerScreen(videoUrl: exercise.videoUrl!),
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }
}