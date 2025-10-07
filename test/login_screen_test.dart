import 'package:fit_ai/providers/user_provider.dart';
import 'package:fit_ai/screens/login_screen.dart';
import 'package:fit_ai/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_screen_test.mocks.dart';

@GenerateMocks([AuthService, NavigatorObserver])
void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthService mockAuthService;
    late MockNavigatorObserver mockNavigatorObserver;

    setUp(() {
      mockAuthService = MockAuthService();
      mockNavigatorObserver = MockNavigatorObserver();
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
        child: MaterialApp(
          home: const LoginScreen(),
          navigatorObservers: [mockNavigatorObserver],
        ),
      );
    }

    testWidgets('renders all required UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Welcome Back to FitAI'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      expect(
          find.widgetWithText(ElevatedButton, 'Sign in with Google'), findsOneWidget);
      expect(find.text("Don't have an account? Sign Up"), findsOneWidget);
    });

    testWidgets('shows validation error for empty email and password',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(
          find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('does not show validation errors for valid input',
        (WidgetTester tester) async {
      when(mockAuthService.signInWithEmail(
              email: 'test@test.com', password: 'password'))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'test@test.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'password');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsNothing);
      expect(
          find.text('Password must be at least 6 characters'), findsNothing);
    });
  });
}