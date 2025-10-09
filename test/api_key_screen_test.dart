import 'package:fit_ai/providers/api_key_provider.dart';
import 'package:fit_ai/screens/api_key_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_key_screen_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ApiKeyNotifier>()])
void main() {
  group('ApiKeyScreen Widget Tests', () {
    late MockApiKeyNotifier mockApiKeyNotifier;

    setUp(() {
      mockApiKeyNotifier = MockApiKeyNotifier();
      SharedPreferences.setMockInitialValues({});
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          apiKeyProvider.overrideWith((ref) => mockApiKeyNotifier),
        ],
        child: const MaterialApp(
          home: ApiKeyScreen(),
        ),
      );
    }

    testWidgets('renders all required UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Enter OpenAI API Key'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'OpenAI API Key'),
          findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Save and Continue'),
          findsOneWidget);
    });

    testWidgets('shows validation error for invalid API key format',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField), 'invalid-key');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter a valid OpenAI API key'), findsOneWidget);
    });

    testWidgets('shows validation error for empty API key',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your API key'), findsOneWidget);
    });

    testWidgets(
        'calls saveApiKey when a valid key is entered and button is pressed',
        (WidgetTester tester) async {
      const validApiKey = 'sk-valid-key-12345';
      when(mockApiKeyNotifier.saveApiKey(validApiKey))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField), validApiKey);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(mockApiKeyNotifier.saveApiKey(validApiKey)).called(1);
    });
  });
}