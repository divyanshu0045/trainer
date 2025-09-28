import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutPlan {
  final String id;
  final String userId;
  final List<DailyWorkout> dailyWorkouts;
  final DateTime startDate;
  final DateTime endDate;

  WorkoutPlan({
    required this.id,
    required this.userId,
    required this.dailyWorkouts,
    required this.startDate,
    required this.endDate,
  });

  factory WorkoutPlan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WorkoutPlan(
      id: doc.id,
      userId: data['userId'],
      dailyWorkouts: (data['dailyWorkouts'] as List<dynamic>)
          .map((e) => DailyWorkout.fromMap(e))
          .toList(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'dailyWorkouts': dailyWorkouts.map((e) => e.toMap()).toList(),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }
}

class DailyWorkout {
  final String day;
  final List<Exercise> exercises;
  bool isCompleted;

  DailyWorkout({
    required this.day,
    required this.exercises,
    this.isCompleted = false,
  });

  factory DailyWorkout.fromMap(Map<String, dynamic> map) {
    return DailyWorkout(
      day: map['day'],
      exercises: (map['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromMap(e))
          .toList(),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'isCompleted': isCompleted,
    };
  }
}

class Exercise {
  final String name;
  final String sets;
  final String reps;
  final String rest;
  final String? videoUrl; // Optional video demo URL

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.rest,
    this.videoUrl,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    // Provide a default placeholder video if the AI response doesn't include one.
    final videoUrl = map['videoUrl'] as String? ??
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4';

    return Exercise(
      name: map['name'],
      sets: map['sets'],
      reps: map['reps'],
      rest: map['rest'],
      videoUrl: videoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'rest': rest,
      'videoUrl': videoUrl,
    };
  }
}