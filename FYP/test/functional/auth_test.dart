import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_recognition_app/models/user_model.dart';
import 'package:food_recognition_app/viewmodels/vm_login.dart';
import 'package:food_recognition_app/viewmodels/vm_signup.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  group('Authentication - LoginViewModel', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore mockFirestore;
    late LoginViewModel loginViewModel;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      mockAuth = MockFirebaseAuth();
      mockFirestore = FakeFirebaseFirestore();
      UserModel.setMockInstances(mockAuth, mockFirestore);
      loginViewModel = LoginViewModel();
    });

    testWidgets('[Auth] Reject login if either field is empty', (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Builder(
                  builder: (context) => ElevatedButton(
                        onPressed: () => loginViewModel.authAction(
                            LoginAction.login, context),
                        child: const Text('Login'),
                      )))));

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(loginViewModel.isLoading, false);
      expect(mockAuth.currentUser, isNull);
    });

    testWidgets('[Auth] Display an error message if authentication fails',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Builder(
                  builder: (context) => ElevatedButton(
                        onPressed: () {
                          loginViewModel.emailController.text =
                              'wrong@email.com';
                          loginViewModel.passwordController.text = 'wrongpass';
                          loginViewModel.authAction(LoginAction.login, context);
                        },
                        child: const Text('Login'),
                      )))));

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Login failed'), findsOneWidget);
    });

    testWidgets('[Auth] Allow user to log in using email and password',
        (tester) async {
      final mockUser = MockUser(
        isAnonymous: false,
        uid: 'user123',
        email: 'test@test.com',
      );
      mockAuth = MockFirebaseAuth(mockUser: mockUser);
      UserModel.setMockInstances(mockAuth, mockFirestore);

      await tester.pumpWidget(MaterialApp(
          routes: {
            '/main': (context) => const Scaffold(body: Text('Main Page')),
          },
          home: Scaffold(
              body: Builder(
                  builder: (context) => ElevatedButton(
                        onPressed: () {
                          loginViewModel.emailController.text = 'test@test.com';
                          loginViewModel.passwordController.text =
                              'password123';
                          loginViewModel.authAction(LoginAction.login, context);
                        },
                        child: const Text('Login'),
                      )))));

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Main Page'), findsOneWidget);
    });

    testWidgets('[Auth] Provide navigation to the signup page', (tester) async {
      final mockObserver = MockNavigatorObserver();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
                builder: (context) => ElevatedButton(
                      onPressed: () => loginViewModel.authAction(
                          LoginAction.goToSignup, context),
                      child: const Text('Go'),
                    ))),
        navigatorObservers: [mockObserver],
        routes: {'/signup': (context) => const Scaffold()},
      ));

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
    });

    testWidgets('[Auth] Provide navigation to the forgot password page',
        (tester) async {
      final mockObserver = MockNavigatorObserver();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
                builder: (context) => ElevatedButton(
                      onPressed: () => loginViewModel.authAction(
                          LoginAction.goToForgotPassword, context),
                      child: const Text('Go'),
                    ))),
        navigatorObservers: [mockObserver],
        routes: {'/forgot_password': (context) => const Scaffold()},
      ));

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
    });
  });

  group('Authentication - SignupViewModel', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore mockFirestore;
    late SignupViewModel signupViewModel;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockAuth = MockFirebaseAuth();
      mockFirestore = FakeFirebaseFirestore();
      UserModel.setMockInstances(mockAuth, mockFirestore);
      signupViewModel = SignupViewModel();
    });

    testWidgets(
        '[Auth] Reject signup if password and confirm password do not match',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
                builder: (context) => ElevatedButton(
                      onPressed: () {
                        signupViewModel.nameController.text = 'John';
                        signupViewModel.emailController.text = 'test@test.com';
                        signupViewModel.passwordController.text =
                            'StrongPass1!';
                        signupViewModel.confirmPasswordController.text =
                            'StrongPass1!@Mismatched';
                        signupViewModel.signupAction(
                            SignupAction.signup, context);
                      },
                      child: const Text('Signup'),
                    ))),
      ));

      await tester.tap(find.text('Signup'));
      await tester.pump();

      expect(signupViewModel.isLoading, false);
      expect(mockAuth.currentUser, isNull);
    });

    testWidgets(
        '[Auth] Allow user to create an account with email and password',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Page')),
          },
          home: Scaffold(
              body: Builder(
                  builder: (context) => ElevatedButton(
                        onPressed: () {
                          signupViewModel.nameController.text = 'John Doe';
                          signupViewModel.emailController.text =
                              'newuser@test.com';
                          signupViewModel.passwordController.text =
                              'StrongPass1!';
                          signupViewModel.confirmPasswordController.text =
                              'StrongPass1!';
                          signupViewModel.signupAction(
                              SignupAction.signup, context);
                        },
                        child: const Text('Signup'),
                      )))));

      await tester.tap(find.text('Signup'));
      await tester.pumpAndSettle();

      expect(find.text('Login Page'), findsOneWidget);
      final userDocs = await mockFirestore.collection('users').get();
      expect(userDocs.docs.length, 1);
      expect(userDocs.docs.first.data()['name'], 'John Doe');
    });
  });
}
