import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';

// ViewModels
import 'viewmodels/vm_home.dart';
import 'viewmodels/vm_login.dart';
import 'viewmodels/vm_signup.dart';
import 'viewmodels/vm_forgotpassword.dart';
import 'viewmodels/vm_changepassword.dart';
import 'viewmodels/vm_history.dart';
import 'viewmodels/vm_calorieresult.dart';
import 'viewmodels/vm_wellnessinsight.dart';
import 'viewmodels/vm_navigation.dart';
import 'viewmodels/vm_insight.dart';
import 'viewmodels/vm_insight_stats.dart';
import 'viewmodels/vm_mealdetail.dart';
import 'viewmodels/vm_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Firebase Initialized Successfully');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
        ChangeNotifierProvider(create: (_) => ChangePasswordViewModel()),
        ChangeNotifierProvider(create: (_) => HistoryViewModel()),
        ChangeNotifierProvider(create: (_) => CalorieResultViewModel()),
        ChangeNotifierProvider(create: (_) => WellnessInsightViewModel()),
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        ChangeNotifierProvider(create: (_) => InsightViewModel()),
        ChangeNotifierProvider(create: (_) => InsightStatsViewModel()),
        ChangeNotifierProvider(create: (_) => MealDetailViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}
