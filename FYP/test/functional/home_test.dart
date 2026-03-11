import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_recognition_app/models/food_item_model.dart';
import 'package:food_recognition_app/viewmodels/vm_home.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  group('Home Page', () {
    late MockImagePicker mockPicker;
    late HomeViewModel homeViewModel;

    setUp(() {
      mockPicker = MockImagePicker();
      homeViewModel = HomeViewModel();
    });

    testWidgets(
        '[Home] Allow user to capture a food image using the device camera',
        (tester) async {
      when(() => mockPicker.pickImage(source: ImageSource.camera))
          .thenAnswer((_) async => XFile('camera_image.jpg'));

      homeViewModel.setMockDependencies(mockPicker, (path) async => []);

      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Builder(
                  builder: (context) => ElevatedButton(
                        onPressed: () => homeViewModel.foodRecognition(
                            FoodRecognitionAction.takePhoto, context),
                        child: const Text('Camera'),
                      )))));

      await tester.tap(find.text('Camera'));
      await tester.pump();

      expect(homeViewModel.capturedImage?.path, 'camera_image.jpg');
      verify(() => mockPicker.pickImage(source: ImageSource.camera)).called(1);
    });

    testWidgets(
        '[Home] Allow user to upload a food image from the device gallery',
        (tester) async {
      when(() => mockPicker.pickImage(source: ImageSource.gallery))
          .thenAnswer((_) async => XFile('gallery_image.jpg'));

      homeViewModel.setMockDependencies(mockPicker, (path) async => []);

      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Builder(
                  builder: (context) => ElevatedButton(
                        onPressed: () => homeViewModel.foodRecognition(
                            FoodRecognitionAction.uploadImage, context),
                        child: const Text('Gallery'),
                      )))));

      await tester.tap(find.text('Gallery'));
      await tester.pump();

      expect(homeViewModel.capturedImage?.path, 'gallery_image.jpg');
      verify(() => mockPicker.pickImage(source: ImageSource.gallery)).called(1);
    });

    testWidgets(
        '[Home] Provide an option to initiate food recognition after an image is selected',
        (tester) async {
      final mockObserver = MockNavigatorObserver();

      bool analyzerCalled = false;
      homeViewModel.capturedImage = XFile('test_image.jpg');
      homeViewModel.setMockDependencies(mockPicker, (path) async {
        analyzerCalled = true;
        expect(path, 'test_image.jpg');
        return [
          FoodItemModel(
              name: 'Apple',
              confidence: 'High',
              status: 'Detected',
              calories: 95)
        ];
      });

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
                        onPressed: () => homeViewModel.foodRecognition(
                            FoodRecognitionAction.analyze, context),
                        child: const Text('Analyze'),
                      )))));

      await tester.tap(find.text('Analyze'));
      await tester.pumpAndSettle();

      expect(analyzerCalled, true);
      expect(homeViewModel.lastResults.length, 1);
      expect(homeViewModel.lastResults.first.name, 'Apple');

      // Verification of navigation
      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
      expect(find.text('Insight Page'), findsOneWidget);
    });

    testWidgets(
        '[Home] Handle cases where user initiates analysis without selecting an image',
        (tester) async {
      final mockObserver = MockNavigatorObserver();

      // Simulate analysis throwing an error or handling empty string gracefully
      homeViewModel.capturedImage = null; // No image selected
      homeViewModel.setMockDependencies(mockPicker, (path) async {
        if (path.isEmpty) throw Exception('No image found!');
        return [];
      });

      await tester.pumpWidget(MaterialApp(
          navigatorObservers: [mockObserver],
          home: Scaffold(
              body: Builder(
                  builder: (context) => ElevatedButton(
                        onPressed: () => homeViewModel.foodRecognition(
                            FoodRecognitionAction.analyze, context),
                        child: const Text('Analyze Empty'),
                      )))));

      await tester.tap(find.text('Analyze Empty'));
      await tester.pumpAndSettle();

      // Ensure error is caught and SnackBar is displayed
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Analyze failed'), findsOneWidget);
      expect(homeViewModel.isAnalyzing, false);
    });
  });
}
