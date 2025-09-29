import 'package:fit_ai/providers/api_key_provider.dart';
import 'package:fit_ai/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fit_ai/services/auth_service.dart';
import 'package:fit_ai/providers/user_provider.dart';

// Mocks
class MockAuthService extends Mock implements AuthService {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthService mockAuthService;
    late MockNavigatorObserver mockNavigatorObserver;

    setUp(() {
      mockAuthService = MockAuthService();
      mockNavigatorObserver = MockNavigatorObserver();
    });

    // A helper function to build the widget for testing
    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          // Override the authServiceProvider to use our mock
          authServiceProvider.overrideWithValue(mockAuthService),
          // We also need to provide a default for the apiKeyProvider
          apiKeyProvider.overrideWith((ref) => ApiKeyNotifier(ref.watch(storageServiceProvider))),
        ],
        child: MaterialApp(
          home: const LoginScreen(),
          navigatorObservers: [mockNavigatorObserver],
        ),
      );
    }

    testWidgets('renders all required UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify that the title, text fields, and buttons are present.
      expect(find.text('Welcome Back to FitAI'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign in with Google'), findsOneWidget);
      expect(find.text("Don't have an account? Sign Up"), findsOneWidget);
    });

    testWidgets('shows validation error for empty email and password', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap the login button without entering any text
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump(); // Rebuild the widget to show validation messages

      // Verify that validation errors are shown
      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('does not show validation errors for valid input', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // We need to provide a mock response for the login attempt
      when(mockAuthService.signInWithEmail(email: 'test@test.com', password: 'password'))
          .thenAnswer((_) async => null); // Return null as if successful

      // Enter valid text
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@test.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password');

      // Tap the login button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      // Verify that no validation errors are shown
      expect(find.text('Please enter a valid email'), findsNothing);
      expect(find.text('Password must be at least 6 characters'), findsNothing);
    });
  });
}