import 'package:firebase_core/firebase_core.dart';
import 'package:fit_ai/providers/api_key_provider.dart';
import 'package:fit_ai/screens/api_key_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_ai/providers/user_provider.dart';
import 'package:fit_ai/providers/notification_provider.dart';
import 'package:fit_ai/screens/home_screen.dart';
import 'package:fit_ai/screens/login_screen.dart';
import 'package:fit_ai/screens/onboarding_screen.dart';
import 'package:fit_ai/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Create a ProviderContainer to initialize services before the app runs.
  final container = ProviderContainer();
  await container.read(initializeNotificationProvider.future);

  runApp(
    // Pass the same container to the ProviderScope to ensure state is maintained.
    ProviderScope(
      parent: container,
      child: const FitAiApp(),
    ),
  );
}

class FitAiApp extends StatelessWidget {
  const FitAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitAI',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AppInitializer(), // New entry point checks for API key first
    );
  }
}

// This new widget acts as the root, checking for the API key before anything else.
class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiKeyAsync = ref.watch(apiKeyProvider);

    return apiKeyAsync.when(
      data: (apiKey) {
        // If the API key is missing, show the screen to enter it.
        if (apiKey == null || apiKey.isEmpty) {
          return const ApiKeyScreen();
        }
        // If the API key exists, proceed to the normal authentication flow.
        return const AuthWrapper();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        body: Center(child: Text('Fatal Error: Could not load API Key. $e')),
      ),
    );
  }
}

// This wrapper handles the user authentication state *after* the API key is confirmed to exist.
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // If the user is logged in, check if they have a profile
          final userProfile = ref.watch(userProvider);
          return userProfile.when(
            data: (profile) {
              if (profile != null) {
                return const HomeScreen();
              }
              // If user is logged in but has no profile, go to onboarding
              return OnboardingScreen();
            },
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
          );
        }
        // If user is not logged in, show the login screen
        return const LoginScreen();
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Authentication Error: $e'))),
    );
  }
}