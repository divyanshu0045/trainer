import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String userId;
  final DateTime date;
  final int energyLevel; // 1-5 scale
  final int hungerLevel; // 1-5 scale
  final int sleepQuality; // 1-5 scale
  final double adherenceRate; // 0-100%
  final String comments;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.energyLevel,
    required this.hungerLevel,
    required this.sleepQuality,
    required this.adherenceRate,
    required this.comments,
  });

  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FeedbackModel(
      id: doc.id,
      userId: data['userId'],
      date: (data['date'] as Timestamp).toDate(),
      energyLevel: data['energyLevel'],
      hungerLevel: data['hungerLevel'],
      sleepQuality: data['sleepQuality'],
      adherenceRate: (data['adherenceRate'] ?? 0.0).toDouble(),
      comments: data['comments'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'energyLevel': energyLevel,
      'hungerLevel': hungerLevel,
      'sleepQuality': sleepQuality,
      'adherenceRate': adherenceRate,
      'comments': comments,
    };
  }
}