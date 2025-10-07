import 'package:fit_ai/models/user_model.dart';
import 'package:fit_ai/providers/user_provider.dart';
import 'package:fit_ai/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'profile_screen_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UserDataNotifier>()])
void main() {
  group('ProfileScreen Widget Tests', () {
    late MockUserDataNotifier mockUserDataNotifier;
    late UserModel mockUser;

    setUp(() {
      mockUserDataNotifier = MockUserDataNotifier();
      mockUser = UserModel(
        id: 'test_id',
        name: 'Test User',
        email: 'test@test.com',
        age: 30,
        gender: 'Male',
        height: 180,
        weight: 80,
        fitnessGoal: 'Gain Muscle',
        activityLevel: 'Moderately Active',
        dietaryPreferences: 'None',
      );
      // When the provider's state is first read, return the mock user.
      when(mockUserDataNotifier.state).thenReturn(AsyncValue.data(mockUser));
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          userProvider.overrideWith((ref) => mockUserDataNotifier),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      );
    }

    testWidgets('renders and populates form fields with user data',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Let the initial frame render

      expect(find.widgetWithText(TextFormField, 'Test User'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '30'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '180.0'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '80.0'), findsOneWidget);
      expect(find.text('Gain Muscle'), findsOneWidget);
    });

    testWidgets('allows user to edit a field', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Test User'), 'Updated Name');
      await tester.pump();

      expect(find.text('Updated Name'), findsOneWidget);
    });

    testWidgets('save button updates the user profile',
        (WidgetTester tester) async {
      when(mockUserDataNotifier.saveUser(any)).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Test User'), 'Updated Name');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      final captured =
          verify(mockUserDataNotifier.saveUser(captureAny)).captured;
      expect(captured.single, isA<UserModel>());
      expect((captured.single as UserModel).name, 'Updated Name');
      expect((captured.single as UserModel).age, 30);

      expect(find.text('Profile updated successfully!'), findsOneWidget);
    });
  });
}