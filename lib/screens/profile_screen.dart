import 'package:fit_ai/models/user_model.dart';
import 'package:fit_ai/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String? _gender;
  String? _fitnessGoal;
  String? _activityLevel;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider).value;

    // Initialize controllers with current user data
    _nameController = TextEditingController(text: user?.name ?? '');
    _ageController = TextEditingController(text: user?.age.toString() ?? '');
    _heightController = TextEditingController(text: user?.height.toString() ?? '');
    _weightController = TextEditingController(text: user?.weight.toString() ?? '');
    _gender = user?.gender;
    _fitnessGoal = user?.fitnessGoal;
    _activityLevel = user?.activityLevel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final originalUser = ref.read(userProvider).value;
      if (originalUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Could not find user to update.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Create a new UserModel with updated data
      final updatedUser = UserModel(
        id: originalUser.id,
        email: originalUser.email,
        name: _nameController.text,
        age: int.parse(_ageController.text),
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        gender: _gender!,
        fitnessGoal: _fitnessGoal!,
        activityLevel: _activityLevel!,
        dietaryPreferences: originalUser.dietaryPreferences, // Not editable in this screen
        healthConditions: originalUser.healthConditions, // Not editable
      );

      try {
        await ref.read(userProvider.notifier).saveUser(updatedUser);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
            tooltip: 'Save Changes',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: ['Male', 'Female', 'Other'].map((label) => DropdownMenuItem(child: Text(label), value: label,)).toList(),
                      onChanged: (value) => setState(() => _gender = value),
                      validator: (value) => value == null ? 'Please select your gender' : null,
                    ),
                    const SizedBox(height: 16),
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
            ),
    );
  }
}