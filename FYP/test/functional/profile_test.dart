import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:food_recognition_app/models/user_model.dart';
import 'package:food_recognition_app/viewmodels/vm_wellnessinsight.dart';
import 'package:food_recognition_app/viewmodels/vm_login.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  group('Profile (Wellness Insight) Page', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore mockFirestore;
    late WellnessInsightViewModel wellnessViewModel;
    late LoginViewModel loginViewModel;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final mockUser =
          MockUser(isAnonymous: false, uid: 'user123', email: 'test@email.com');
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      mockFirestore = FakeFirebaseFirestore();

      WellnessInsightViewModel.setMockInstances(mockAuth, mockFirestore);
      UserModel.setMockInstances(mockAuth, mockFirestore);

      wellnessViewModel = WellnessInsightViewModel();
      loginViewModel = LoginViewModel();
    });

    testWidgets('[Profile] Retrieve and display current personal information',
        (tester) async {
      expect(wellnessViewModel.email, 'test@email.com');
      expect(wellnessViewModel.nameController.text,
          'John S. Doe'); // Default value
      expect(wellnessViewModel.gender, 'Male');
    });

    testWidgets(
        '[Profile] Allow user to edit and save changes to personal information',
        (tester) async {
      wellnessViewModel.updateName('Jane Doe');
      wellnessViewModel.updateAge(25);
      wellnessViewModel.updateGender('Female');

      expect(wellnessViewModel.nameController.text, 'Jane Doe');
      expect(wellnessViewModel.ageController.text, '25');
      expect(wellnessViewModel.gender, 'Female');
    });

    testWidgets('[Profile] Allow user to logout current account',
        (tester) async {
      final mockObserver = MockNavigatorObserver();

      await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider<WellnessInsightViewModel>.value(
                value: wellnessViewModel),
            ChangeNotifierProvider<LoginViewModel>.value(value: loginViewModel),
          ],
          child: MaterialApp(
              navigatorObservers: [
                mockObserver
              ],
              routes: {
                '/login': (context) => const Scaffold(body: Text('Login Page')),
              },
              home: Scaffold(
                  body: Builder(
                      builder: (context) => ElevatedButton(
                            onPressed: () => context
                                .read<WellnessInsightViewModel>()
                                .wellnessAction(WellnessAction.logout, context),
                            child: const Text('Logout'),
                          ))))));

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
      expect(find.text('Login Page'), findsOneWidget);
    });

    testWidgets('[Profile] Allow user to go to change password screen',
        (tester) async {
      final mockObserver = MockNavigatorObserver();

      await tester.pumpWidget(MaterialApp(
          navigatorObservers: [
            mockObserver
          ],
          routes: {
            '/change_password': (context) =>
                const Scaffold(body: Text('Password Page')),
          },
          home: Scaffold(
              body: Builder(
                  builder: (context) => ElevatedButton(
                        onPressed: () => wellnessViewModel.wellnessAction(
                            WellnessAction.goToChangePassword, context),
                        child: const Text('Password'),
                      )))));

      await tester.tap(find.text('Password'));
      await tester.pumpAndSettle();

      expect(find.text('Password Page'), findsOneWidget);
    });
  });
}
