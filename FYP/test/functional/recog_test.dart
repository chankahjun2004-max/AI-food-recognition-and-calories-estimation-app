import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:food_recognition_app/models/food_item_model.dart';
import 'package:food_recognition_app/viewmodels/vm_insight.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  group('Food Recognition Insight Page', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore mockFirestore;
    late InsightViewModel insightViewModel;

    setUp(() {
      final mockUser = MockUser(isAnonymous: false, uid: 'user123');
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      mockFirestore = FakeFirebaseFirestore();

      InsightViewModel.setMockInstances(mockAuth, mockFirestore);
      insightViewModel = InsightViewModel();
    });

    testWidgets(
        '[Recog] Produce a list of detected food items and load arguments',
        (tester) async {
      final testItems = [
        const FoodItemModel(
            name: 'Apple', confidence: '0.9', status: 'Detected', calories: 95),
        const FoodItemModel(
            name: 'Banana',
            confidence: '0.8',
            status: 'Detected',
            calories: 105),
      ];

      insightViewModel.loadFromArguments({
        'imagePath': 'test_path.jpg',
        'results': testItems,
      });

      expect(insightViewModel.results.length, 2);
      expect(insightViewModel.imagePath, 'test_path.jpg');
      // Auto selects all items by default
      expect(insightViewModel.selectedItems.length, 2);
    });

    testWidgets('[Recog] Toggle food item selection', (tester) async {
      final item = const FoodItemModel(
          name: 'Apple', confidence: '0.9', status: 'Detected', calories: 95);
      insightViewModel.loadFromArguments({
        'results': [item],
      });

      expect(insightViewModel.isSelected(item), true);

      insightViewModel.toggleItemSelection(item);
      expect(insightViewModel.isSelected(item), false);

      insightViewModel.toggleItemSelection(item);
      expect(insightViewModel.isSelected(item), true);
    });

    testWidgets('[Recog] Confirm selection', (tester) async {
      final item = const FoodItemModel(
          name: 'Apple', confidence: '0.9', status: 'Detected', calories: 95);
      insightViewModel.loadFromArguments({
        'results': [item],
      });

      insightViewModel.confirmSelection();
      expect(insightViewModel.showEstimationView, true);
    });

    testWidgets('[Recog] Save to history', (tester) async {
      final item = const FoodItemModel(
          name: 'Apple', confidence: '0.9', status: 'Detected', calories: 95);
      insightViewModel.loadFromArguments({
        'results': [item],
      });

      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Builder(
                  builder: (context) => ElevatedButton(
                        onPressed: () =>
                            insightViewModel.saveToHistory(context),
                        child: const Text('Save'),
                      )))));

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Saved to History!'), findsOneWidget);

      final userDocs = await mockFirestore
          .collection('users')
          .doc('user123')
          .collection('history')
          .get();
      expect(userDocs.docs.length, 1);
      expect(userDocs.docs.first.data()['totalCalories'], 95.0);
    });
  });
}
