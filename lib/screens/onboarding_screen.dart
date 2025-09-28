import 'package:fit_ai/models/user_model.dart';
import 'package:fit_ai/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];

  // Form data
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _gender;
  String? _fitnessGoal;
  String? _activityLevel;
  String? _dietaryPreferences;
  final _healthConditionsController = TextEditingController();

  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _healthConditionsController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_formKeys[_currentPage].currentState!.validate()) {
      if (_currentPage < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        _submitForm();
      }
    }
  }

  Future<void> _submitForm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to create a profile.')),
      );
      // Here you might want to trigger a sign-in flow first.
      // For simplicity, we assume the user is already signed in via Google/Email.
      // A full app would have a login/signup page before this.
      return;
    }

    final userModel = UserModel(
      id: user.uid,
      name: _nameController.text,
      email: user.email!,
      age: int.parse(_ageController.text),
      gender: _gender!,
      height: double.parse(_heightController.text),
      weight: double.parse(_weightController.text),
      fitnessGoal: _fitnessGoal!,
      activityLevel: _activityLevel!,
      dietaryPreferences: _dietaryPreferences!,
      healthConditions: _healthConditionsController.text.split(',').map((e) => e.trim()).toList(),
    );

    await ref.read(userProvider.notifier).saveUser(userModel);
    // Navigation to HomeScreen is handled by the AuthWrapper in main.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Profile'),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: [
          _buildPersonalDetailsPage(),
          _buildFitnessGoalsPage(),
          _buildDietaryPage(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _nextPage,
          child: Text(_currentPage < 2 ? 'Next' : 'Finish'),
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 1: Personal Details', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Please enter your age' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: ['Male', 'Female', 'Other'].map((label) => DropdownMenuItem(child: Text(label), value: label,)).toList(),
              onChanged: (value) => setState(() => _gender = value),
              validator: (value) => value == null ? 'Please select your gender' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Height (cm)'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Please enter your height' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Please enter your weight' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFitnessGoalsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 2: Fitness & Activity', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _fitnessGoal,
              decoration: const InputDecoration(labelText: 'Fitness Goal'),
              items: ['Lose Weight', 'Gain Muscle', 'Maintain Fitness', 'Improve Endurance']
                  .map((label) => DropdownMenuItem(child: Text(label), value: label))
                  .toList(),
              onChanged: (value) => setState(() => _fitnessGoal = value),
              validator: (value) => value == null ? 'Please select a goal' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _activityLevel,
              decoration: const InputDecoration(labelText: 'Activity Level'),
              items: ['Sedentary', 'Lightly Active', 'Moderately Active', 'Very Active']
                  .map((label) => DropdownMenuItem(child: Text(label), value: label))
                  .toList(),
              onChanged: (value) => setState(() => _activityLevel = value),
              validator: (value) => value == null ? 'Please select your activity level' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietaryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 3: Diet & Health', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _dietaryPreferences,
              decoration: const InputDecoration(labelText: 'Dietary Preferences'),
              items: ['None', 'Vegetarian', 'Vegan', 'Gluten-Free', 'Keto']
                  .map((label) => DropdownMenuItem(child: Text(label), value: label))
                  .toList(),
              onChanged: (value) => setState(() => _dietaryPreferences = value),
              validator: (value) => value == null ? 'Please select a preference' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _healthConditionsController,
              decoration: const InputDecoration(
                labelText: 'Health Conditions or Allergies',
                hintText: 'e.g., lactose intolerant, nut allergy (comma-separated)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}