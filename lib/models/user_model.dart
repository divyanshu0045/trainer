import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String fitnessGoal;
  final String activityLevel;
  final String dietaryPreferences;
  final List<String> healthConditions;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.fitnessGoal,
    required this.activityLevel,
    required this.dietaryPreferences,
    this.healthConditions = const [],
  });

  // Factory constructor to create a UserModel from a Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      height: (data['height'] ?? 0.0).toDouble(),
      weight: (data['weight'] ?? 0.0).toDouble(),
      fitnessGoal: data['fitnessGoal'] ?? '',
      activityLevel: data['activityLevel'] ?? '',
      dietaryPreferences: data['dietaryPreferences'] ?? '',
      healthConditions: List<String>.from(data['healthConditions'] ?? []),
    );
  }

  // Method to convert a UserModel to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'fitnessGoal': fitnessGoal,
      'activityLevel': activityLevel,
      'dietaryPreferences': dietaryPreferences,
      'healthConditions': healthConditions,
    };
  }
}