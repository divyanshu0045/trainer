import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feedback_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../providers/user_provider.dart';

class FollowUpScreen extends ConsumerStatefulWidget {
  @override
  _FollowUpScreenState createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends ConsumerState<FollowUpScreen> {
  final _formKey = GlobalKey<FormState>();
  double _energyLevel = 3;
  double _hungerLevel = 3;
  double _sleepQuality = 3;
  double _adherenceRate = 75;
  final _commentsController = TextEditingController();

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(userProvider).value;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not find user. Please log in again.')),
        );
        return;
      }

      final feedback = FeedbackModel(
        id: '', // Firestore will generate an ID
        userId: user.id,
        date: DateTime.now(),
        energyLevel: _energyLevel.toInt(),
        hungerLevel: _hungerLevel.toInt(),
        sleepQuality: _sleepQuality.toInt(),
        adherenceRate: _adherenceRate,
        comments: _commentsController.text,
      );

      try {
        await FirebaseFirestore.instance
            .collection(feedbackCollection)
            .add(feedback.toFirestore());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your feedback! Your plan will be updated soon.')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Follow-Up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How was your week?', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              _buildSlider(
                label: 'Energy Level',
                value: _energyLevel,
                onChanged: (val) => setState(() => _energyLevel = val),
              ),
              _buildSlider(
                label: 'Hunger Level',
                value: _hungerLevel,
                onChanged: (val) => setState(() => _hungerLevel = val),
              ),
              _buildSlider(
                label: 'Sleep Quality',
                value: _sleepQuality,
                onChanged: (val) => setState(() => _sleepQuality = val),
              ),
              _buildSlider(
                label: 'Plan Adherence (%)',
                value: _adherenceRate,
                min: 0,
                max: 100,
                divisions: 10,
                onChanged: (val) => setState(() => _adherenceRate = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _commentsController,
                decoration: const InputDecoration(
                  labelText: 'Additional Comments or Suggestions',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitFeedback,
                  child: const Text('Submit Feedback'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    double min = 1,
    double max = 5,
    int? divisions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleMedium),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions ?? (max - min).toInt(),
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}