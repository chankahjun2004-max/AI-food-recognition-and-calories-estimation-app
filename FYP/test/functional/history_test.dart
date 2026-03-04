import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:food_recognition_app/models/meal_model.dart';
import 'package:food_recognition_app/viewmodels/vm_history.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  group('History Page Tests', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore mockFirestore;
    late HistoryViewModel historyViewModel;
    late MockUser mockUser;

    setUp(() async {
      mockUser = MockUser(isAnonymous: false, uid: 'user123');
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      mockFirestore = FakeFirebaseFirestore();

      // Seed mock firestore with a meal for today
      await mockFirestore
          .collection('users')
          .doc('user123')
          .collection('history')
          .doc('meal1')
          .set({
        'dateTime': DateTime.now().toIso8601String(),
        'totalCalories': 500.0,
        'items': [
          {
            'name': 'Apple',
            'calories': 95.0,
            'confidence': 'High',
            'status': 'Detected'
          }
        ]
      });

      HistoryViewModel.setMockInstances(mockAuth, mockFirestore);
      historyViewModel = HistoryViewModel();

      // Wait for constructor fetch to complete
      await Future.delayed(const Duration(milliseconds: 100));
    });

    testWidgets(
        '[History] Allow user to change dates using next/previous actions',
        (tester) async {
      final initialDate = historyViewModel.selectedDate;

      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Builder(
                  builder: (context) => Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => historyViewModel.historyAction(
                                HistoryAction.previousDay, context),
                            child: const Text('Prev'),
                          ),
                          ElevatedButton(
                            onPressed: () => historyViewModel.historyAction(
                                HistoryAction.nextDay, context),
                            child: const Text('Next'),
                          ),
                        ],
                      )))));

      await tester.tap(find.text('Prev'));
      await tester.pump();

      expect(historyViewModel.selectedDate.day,
          initialDate.subtract(const Duration(days: 1)).day);

      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(historyViewModel.selectedDate.day, initialDate.day);
    });

    testWidgets(
        '[History] Fetch history and calculate total daily calories correctly',
        (tester) async {
      // The setup already injected 500 calories for "today"
      expect(historyViewModel.currentDayMeals.length, 1);
      expect(historyViewModel.totalDailyCalories, 500);
      expect(historyViewModel.currentDayMeals.first.items.first.name, 'Apple');
    });

    testWidgets('[History] Open meal detail action pushes to detail screen',
        (tester) async {
      final mockObserver = MockNavigatorObserver();
      final sampleMeal = MealModel(
        id: 'test',
        dateTime: DateTime.now(),
        items: [],
        totalCalories: 100,
      );

      await tester.pumpWidget(MaterialApp(
          navigatorObservers: [
            mockObserver
          ],
          routes: {
            '/meal_detail': (context) =>
                const Scaffold(body: Text('Meal Detail')),
          },
          home: Scaffold(
              body: Builder(
                  builder: (context) => ElevatedButton(
                        onPressed: () => historyViewModel.historyAction(
                            HistoryAction.openMealDetail, context,
                            data: sampleMeal),
                        child: const Text('Open Detail'),
                      )))));

      await tester.tap(find.text('Open Detail'));
      await tester.pumpAndSettle();

      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
      expect(find.text('Meal Detail'), findsOneWidget);
    });

    testWidgets('[History] Pick date using the date picker', (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Builder(
                  builder: (context) => ElevatedButton(
                        onPressed: () => historyViewModel.historyAction(
                            HistoryAction.pickDate, context),
                        child: const Text('Pick Date'),
                      )))));

      await tester.tap(find.text('Pick Date'));
      await tester.pumpAndSettle();

      // The material date picker dialog should be on screen
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });
}
