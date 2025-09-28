import 'package:fit_ai/widgets/progress_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fit_ai/utils/constants.dart';

class ProgressScreen extends StatelessWidget {
  // Dummy data for the charts. In a real app, this would come from Firestore.
  final List<FlSpot> weightData = const [
    FlSpot(0, 80),
    FlSpot(1, 79.5),
    FlSpot(2, 79),
    FlSpot(3, 78.8),
    FlSpot(4, 78.5),
    FlSpot(5, 78),
    FlSpot(6, 77.5),
  ];

  final List<FlSpot> workoutCompletionData = const [
    FlSpot(0, 100),
    FlSpot(1, 80),
    FlSpot(2, 90),
    FlSpot(3, 100),
    FlSpot(4, 70),
    FlSpot(5, 85),
    FlSpot(6, 95),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        automaticallyImplyLeading: false, // No back button if it's a tab
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Track Your Journey",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            ProgressChart(
              dataPoints: weightData,
              title: "Weight Tracking (kg)",
              lineColor: AppColors.primaryColor,
            ),
            const SizedBox(height: 32),
            ProgressChart(
              dataPoints: workoutCompletionData,
              title: "Workout Adherence (%)",
              lineColor: AppColors.accentColor,
            ),
          ],
        ),
      ),
    );
  }
}