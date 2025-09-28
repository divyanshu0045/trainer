import 'package:fit_ai/providers/plan_provider.dart';
import 'package:fit_ai/providers/user_provider.dart';
import 'package:fit_ai/screens/chat_assistant_screen.dart';
import 'package:fit_ai/screens/progress_screen.dart';
import 'package:fit_ai/screens/settings_screen.dart';
import 'package:fit_ai/screens/workout_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_model.dart';
import '../models/meal_model.dart';
import 'diet_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const _DashboardTab(),
    const _WorkoutTab(),
    const _DietTab(),
    ProgressScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // We can't use ref here, so the logic is moved to the build method.
    // However, if we need to trigger something once, we can use PostFrameCallback.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider).value;
      final plan = ref.read(planProvider);
      if (user != null && !plan.hasValue && !plan.isLoading) {
         ref.read(planProvider.notifier).generatePlans(user);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitAI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => ref.read(userProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Diet'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progress'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatAssistantScreen()),
          );
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}

// --- Dashboard Tab ---
class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planProvider);
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      data: (user) => planAsync.when(
        data: (plans) {
          if (plans.isEmpty || user == null) {
            return const Center(child: Text("Generating your plan..."));
          }
          final workoutPlan = plans['workoutPlan'] as WorkoutPlan?;
          final mealPlan = plans['mealPlan'] as MealPlan?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, ${user.name}!', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                Text("Today's Summary", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                if (workoutPlan?.dailyWorkouts.isNotEmpty ?? false)
                  _SummaryCard(
                    title: "Today's Workout: ${workoutPlan!.dailyWorkouts.first.day}",
                    subtitle: "${workoutPlan.dailyWorkouts.first.exercises.length} exercises",
                    icon: Icons.fitness_center,
                  ),
                if (mealPlan?.dailyMeals.isNotEmpty ?? false)
                  _SummaryCard(
                    title: "Today's Diet: ${mealPlan!.dailyMeals.first.totalCalories} kcal",
                    subtitle: "${mealPlan.dailyMeals.first.meals.length} meals",
                    icon: Icons.fastfood,
                  ),
                const _SummaryCard(
                  title: "Water Intake",
                  subtitle: "8 / 10 glasses (dummy data)",
                  icon: Icons.local_drink,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading plan: $e')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SummaryCard({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

// --- Workout Tab ---
class _WorkoutTab extends ConsumerWidget {
  const _WorkoutTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planProvider);
    return planAsync.when(
      data: (plans) {
        final workoutPlan = plans['workoutPlan'] as WorkoutPlan?;
        if (workoutPlan == null) return const Center(child: Text('No workout plan found.'));

        return ListView.builder(
          itemCount: workoutPlan.dailyWorkouts.length,
          itemBuilder: (context, index) {
            final dailyWorkout = workoutPlan.dailyWorkouts[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text('Day ${index + 1}: ${dailyWorkout.day}'),
                subtitle: Text('${dailyWorkout.exercises.length} exercises'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutDetailScreen(dailyWorkout: dailyWorkout),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

// --- Diet Tab ---
class _DietTab extends ConsumerWidget {
  const _DietTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planProvider);
    return planAsync.when(
      data: (plans) {
        final mealPlan = plans['mealPlan'] as MealPlan?;
        if (mealPlan == null) return const Center(child: Text('No meal plan found.'));

        return ListView.builder(
          itemCount: mealPlan.dailyMeals.length,
          itemBuilder: (context, index) {
            final dailyMeal = mealPlan.dailyMeals[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text('Day ${index + 1}: ${dailyMeal.day}'),
                subtitle: Text('Total Calories: ${dailyMeal.totalCalories} kcal'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DietDetailScreen(dailyMeal: dailyMeal),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}