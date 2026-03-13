import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models/user_model.dart';

import 'package:provider/provider.dart';

import 'theme/tng_theme.dart';
import 'viewmodels/vm_theme.dart';

// Views
import 'views/view_login.dart';
import 'views/view_signup.dart';
import 'views/view_forgotpassword.dart';
import 'views/view_changepassword.dart';
import 'views/main_navigation.dart';
import 'views/view_home.dart';
import 'views/view_insight.dart';
import 'views/view_caloriesresult.dart';
import 'views/view_mealdetail.dart';
import 'views/view_history.dart';
import 'views/view_wellnessinsight.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVm = context.watch<ThemeViewModel>();

    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Food Recognition App',
      debugShowCheckedModeBanner: false,
      theme: TngTheme.light(),
      darkTheme: TngTheme.dark(),
      themeMode: themeVm.themeMode,
      home: const _AppEntry(),
      routes: {
        // Authentication
        '/login': (_) => const LoginView(),
        '/signup': (_) => const SignupView(),
        '/forgot_password': (_) => const ForgotPasswordView(),
        '/change_password': (_) => const ChangePasswordView(),

        // Main navigation shell
        '/main': (_) => const MainNavigation(),

        // Core features
        '/home': (_) => const HomeView(),
        '/insight': (_) => const InsightView(),
        '/calorie_result': (_) => const CalorieResultView(),
        '/meal_detail': (_) => const MealDetailView(),
        '/history': (_) => const HistoryView(),
        '/wellness': (_) => const WellnessInsightView(),
      },
    );
  }
}

class _AppEntry extends StatelessWidget {
  const _AppEntry();

  Future<bool> _openMain() async {
    final rememberMe = await UserModel.getRememberMe();
    final user = FirebaseAuth.instance.currentUser;

    // If remember-me is off, force a fresh login each app launch.
    if (!rememberMe) {
      if (user != null) {
        await FirebaseAuth.instance.signOut();
      }
      return false;
    }

    // Remember-me is on: go straight in only if Firebase already has a session.
    return user != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _openMain(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final goMain = snapshot.data == true;
        return goMain ? const MainNavigation() : const LoginView();
      },
    );
  }
}
