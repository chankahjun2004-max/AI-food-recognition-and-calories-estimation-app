import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_recognition_app/viewmodels/vm_calorieresult.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  group('Calories Estimation Page', () {
    late CalorieResultViewModel calorieViewModel;

    setUp(() {
      calorieViewModel = CalorieResultViewModel();
    });

    testWidgets(
        '[Calories] Allow the user to save the estimated meal records by pressing a Save button',
        (tester) async {
      final mockObserver = MockNavigatorObserver();

      await tester.pumpWidget(MaterialApp(
          navigatorObservers: [mockObserver],
          home: Scaffold(
            body: Builder(
              builder: (navContext) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      navContext,
                      MaterialPageRoute(
                          builder: (context) => Scaffold(
                              body: Builder(
                                  builder: (buttonContext) => ElevatedButton(
                                        onPressed: () =>
                                            calorieViewModel.calorieAction(
                                                CalorieAction.confirmAndSave,
                                                buttonContext),
                                        child: const Text('Save'),
                                      )))));
                },
                child: const Text('Open Page'),
              ),
            ),
          )));

      // Open the page
      await tester.tap(find.text('Open Page'));
      await tester.pumpAndSettle();

      // Tap the save button inside the new page
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Ensure Navigation.pop was called
      verify(() => mockObserver.didPop(any(), any())).called(1);

      // Ensure successful SnackBar was displayed on the remaining root scaffold
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Meal Logged to History!'), findsOneWidget);
    });

    testWidgets('[Calories] Allow user to go back to previous screen',
        (tester) async {
      final mockObserver = MockNavigatorObserver();

      await tester.pumpWidget(MaterialApp(
          navigatorObservers: [mockObserver],
          home: Scaffold(
              body: Builder(
                  builder: (context) => ElevatedButton(
                        onPressed: () => calorieViewModel.calorieAction(
                            CalorieAction.goBack, context),
                        child: const Text('Back'),
                      )))));

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      // Ensure Navigation.pop was called
      verify(() => mockObserver.didPop(any(), any())).called(1);
    });

    testWidgets('[Calories] Display error message method works',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Builder(
                  builder: (context) => ElevatedButton(
                        onPressed: () => calorieViewModel.displayError(
                            context, 'Test Error Message'),
                        child: const Text('Error'),
                      )))));

      await tester.tap(find.text('Error'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Test Error Message'), findsOneWidget);
    });

    testWidgets('[Calories] Direct to insight page', (tester) async {
      final mockObserver = MockNavigatorObserver();

      await tester.pumpWidget(MaterialApp(
          navigatorObservers: [
            mockObserver
          ],
          routes: {
            '/insight': (context) => const Scaffold(body: Text('Insight Page')),
          },
          home: Scaffold(
              body: Builder(
                  builder: (context) => ElevatedButton(
                        onPressed: () =>
                            calorieViewModel.directToResult(context),
                        child: const Text('Direct'),
                      )))));

      await tester.tap(find.text('Direct'));
      await tester.pumpAndSettle();

      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
      expect(find.text('Insight Page'), findsOneWidget);
    });
  });
}
