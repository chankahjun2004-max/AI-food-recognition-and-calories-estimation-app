import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/meal_model.dart';

import '../models/user_model.dart';
import 'vm_login.dart';

enum NutrientKey {
  calories,
  protein,
  carbs,
  fat,
  fiber,
  sugar,
  sodium,
}

class NutrientGoal {
  final NutrientKey key;
  final String label;
  final String unit;
  final IconData icon;
  double target;
  double consumed;

  NutrientGoal({
    required this.key,
    required this.label,
    required this.unit,
    required this.icon,
    required this.target,
    required this.consumed,
  });

  double get ratio => target <= 0 ? 0 : consumed / target;
}

enum WellnessAction {
  goToChangePassword,
  logout,
}

class WellnessInsightViewModel extends ChangeNotifier {
  // COLORS
  final Color primaryColor = const Color(0xFF2D62ED);

  bool isLoading = false;

  WellnessInsightViewModel() {
    fetchWellnessData();
  }

  Future<void> fetchWellnessData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .orderBy('dateTime', descending: true)
          .get();

      final now = DateTime.now();

      double todayCalories = 0;
      double todayProtein = 0;
      double todayCarbs = 0;
      double todayFat = 0;

      List<double> weekCalories = List.filled(7, 0.0);
      List<double> weekProtein = List.filled(7, 0.0);
      List<double> weekCarbs = List.filled(7, 0.0);
      List<double> weekFat = List.filled(7, 0.0);

      // Find the start of the current week (Monday)
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekDate =
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

      for (var doc in snapshot.docs) {
        var data = doc.data();
        data['id'] = doc.id;
        final meal = MealModel.fromJson(data);

        // Check if meal is today
        if (meal.dateTime.year == now.year &&
            meal.dateTime.month == now.month &&
            meal.dateTime.day == now.day) {
          todayCalories += meal.totalCalories;
          for (var item in meal.items) {
            todayProtein += item.protein ?? 0;
            todayCarbs += item.carbs ?? 0;
            todayFat += item.fat ?? 0;
          }
        }

        // Check if meal is within the current week (Mon-Sun)
        final mealDate = DateTime(
            meal.dateTime.year, meal.dateTime.month, meal.dateTime.day);
        if (!mealDate.isBefore(startOfWeekDate) &&
            mealDate.isBefore(startOfWeekDate.add(const Duration(days: 7)))) {
          // weekday is 1=Mon, 7=Sun. Our index is 0..6
          final idx = meal.dateTime.weekday - 1;

          weekCalories[idx] += meal.totalCalories;
          for (var item in meal.items) {
            weekProtein[idx] += item.protein ?? 0;
            weekCarbs[idx] += item.carbs ?? 0;
            weekFat[idx] += item.fat ?? 0;
          }
        }
      }

      setDailyConsumed(todayCalories.toInt());
      goals[NutrientKey.protein]!.consumed = todayProtein;
      goals[NutrientKey.carbs]!.consumed = todayCarbs;
      goals[NutrientKey.fat]!.consumed = todayFat;

      // Default missing nutrients to 0 if not tracked
      goals[NutrientKey.fiber]!.consumed = 0;
      goals[NutrientKey.sugar]!.consumed = 0;
      goals[NutrientKey.sodium]!.consumed = 0;

      trendSeries[NutrientKey.calories] =
          List.generate(7, (i) => FlSpot(i.toDouble(), weekCalories[i]));
      trendSeries[NutrientKey.protein] =
          List.generate(7, (i) => FlSpot(i.toDouble(), weekProtein[i]));
      trendSeries[NutrientKey.carbs] =
          List.generate(7, (i) => FlSpot(i.toDouble(), weekCarbs[i]));
      trendSeries[NutrientKey.fat] =
          List.generate(7, (i) => FlSpot(i.toDouble(), weekFat[i]));
      trendSeries[NutrientKey.fiber] =
          List.generate(7, (i) => FlSpot(i.toDouble(), 0));
      trendSeries[NutrientKey.sugar] =
          List.generate(7, (i) => FlSpot(i.toDouble(), 0));
      trendSeries[NutrientKey.sodium] =
          List.generate(7, (i) => FlSpot(i.toDouble(), 0));
    } catch (e) {
      print("Error fetching wellness data: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // PERSONAL INFO
  final TextEditingController nameController =
      TextEditingController(text: "John S. Doe");
  final TextEditingController ageController = TextEditingController(text: "22");
  final TextEditingController heightController =
      TextEditingController(text: "175");
  final TextEditingController weightController =
      TextEditingController(text: "70");
  String gender = "Male";

  String get email =>
      FirebaseAuth.instance.currentUser?.email ?? 'Unknown Email';

  // DASHBOARD / TODAY
  int dailyConsumed = 1540;
  int dailyTarget = 2000;

  double get dailyPercent => dailyTarget == 0 ? 0 : dailyConsumed / dailyTarget;

  /// Week labels for the trend chart (0..6)
  final List<String> weekLabels = const [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// Nutrient goals shown in the Insights tab.
  /// NOTE: Sample values — wire these to your actual food log totals.
  late final Map<NutrientKey, NutrientGoal> goals = {
    NutrientKey.calories: NutrientGoal(
      key: NutrientKey.calories,
      label: 'Calories',
      unit: 'kcal',
      icon: Icons.local_fire_department,
      target: dailyTarget.toDouble(),
      consumed: dailyConsumed.toDouble(),
    ),
    NutrientKey.protein: NutrientGoal(
      key: NutrientKey.protein,
      label: 'Protein',
      unit: 'g',
      icon: Icons.fitness_center,
      target: 120,
      consumed: 86,
    ),
    NutrientKey.carbs: NutrientGoal(
      key: NutrientKey.carbs,
      label: 'Carbs',
      unit: 'g',
      icon: Icons.bakery_dining,
      target: 250,
      consumed: 210,
    ),
    NutrientKey.fat: NutrientGoal(
      key: NutrientKey.fat,
      label: 'Fat',
      unit: 'g',
      icon: Icons.opacity,
      target: 70,
      consumed: 62,
    ),
    NutrientKey.fiber: NutrientGoal(
      key: NutrientKey.fiber,
      label: 'Fiber',
      unit: 'g',
      icon: Icons.grass,
      target: 30,
      consumed: 18,
    ),
    NutrientKey.sugar: NutrientGoal(
      key: NutrientKey.sugar,
      label: 'Sugar',
      unit: 'g',
      icon: Icons.icecream,
      target: 50,
      consumed: 58,
    ),
    NutrientKey.sodium: NutrientGoal(
      key: NutrientKey.sodium,
      label: 'Sodium',
      unit: 'mg',
      icon: Icons.water_drop,
      target: 2300,
      consumed: 2400,
    ),
  };

  NutrientKey selectedTrend = NutrientKey.calories;

  /// Trend data per nutrient (0..6 = Mon..Sun).
  final Map<NutrientKey, List<FlSpot>> trendSeries = {
    NutrientKey.calories: const [
      FlSpot(0, 1850),
      FlSpot(1, 2100),
      FlSpot(2, 1980),
      FlSpot(3, 1750),
      FlSpot(4, 2200),
      FlSpot(5, 2050),
      FlSpot(6, 1900),
    ],
    NutrientKey.protein: const [
      FlSpot(0, 95),
      FlSpot(1, 110),
      FlSpot(2, 88),
      FlSpot(3, 102),
      FlSpot(4, 120),
      FlSpot(5, 98),
      FlSpot(6, 105),
    ],
    NutrientKey.carbs: const [
      FlSpot(0, 210),
      FlSpot(1, 250),
      FlSpot(2, 195),
      FlSpot(3, 230),
      FlSpot(4, 270),
      FlSpot(5, 240),
      FlSpot(6, 205),
    ],
    NutrientKey.fat: const [
      FlSpot(0, 55),
      FlSpot(1, 70),
      FlSpot(2, 62),
      FlSpot(3, 58),
      FlSpot(4, 75),
      FlSpot(5, 66),
      FlSpot(6, 60),
    ],
    NutrientKey.fiber: const [
      FlSpot(0, 22),
      FlSpot(1, 28),
      FlSpot(2, 18),
      FlSpot(3, 24),
      FlSpot(4, 30),
      FlSpot(5, 21),
      FlSpot(6, 26),
    ],
    NutrientKey.sugar: const [
      FlSpot(0, 40),
      FlSpot(1, 55),
      FlSpot(2, 45),
      FlSpot(3, 38),
      FlSpot(4, 60),
      FlSpot(5, 52),
      FlSpot(6, 47),
    ],
    NutrientKey.sodium: const [
      FlSpot(0, 1900),
      FlSpot(1, 2400),
      FlSpot(2, 2100),
      FlSpot(3, 1800),
      FlSpot(4, 2600),
      FlSpot(5, 2250),
      FlSpot(6, 2000),
    ],
  };

  List<FlSpot> get trendData => trendSeries[selectedTrend] ?? const [];

  NutrientGoal get selectedTrendGoal =>
      goals[selectedTrend] ?? goals[NutrientKey.calories]!;

  void setSelectedTrend(NutrientKey key) {
    if (selectedTrend == key) return;
    selectedTrend = key;
    notifyListeners();
  }

  /// Color rules:
  /// - exceeded: red
  /// - near target (>= 90%): orange
  /// - on track: primary
  Color goalColor(double ratio) {
    if (ratio > 1.0) return Colors.red;
    if (ratio >= 0.9) return Colors.orange;
    return primaryColor;
  }

  void _syncCaloriesGoal() {
    final c = goals[NutrientKey.calories];
    if (c == null) return;
    c.consumed = dailyConsumed.toDouble();
    c.target = dailyTarget.toDouble();
  }

  /// Call these from your data layer when today's totals/targets change.
  void setDailyTarget(int target) {
    dailyTarget = target;
    _syncCaloriesGoal();
    notifyListeners();
  }

  void setDailyConsumed(int consumed) {
    dailyConsumed = consumed;
    _syncCaloriesGoal();
    notifyListeners();
  }

  // ==========================================================
  // NEW: Per-nutrient target setters (used by the Insight view)
  // ==========================================================
  void setNutrientTarget(NutrientKey key, double target) {
    final g = goals[key];
    if (g == null) return;

    g.target = target;

    // Keep dailyTarget synced if calories target changes
    if (key == NutrientKey.calories) {
      dailyTarget = target.round();
      _syncCaloriesGoal();
    }

    notifyListeners();
  }

  /// NEW: slider bounds per nutrient (nice UX)
  ({double min, double max, double step}) sliderBoundsFor(NutrientKey key) {
    switch (key) {
      case NutrientKey.calories:
        return (min: 1000, max: 4500, step: 50);
      case NutrientKey.protein:
        return (min: 20, max: 250, step: 5);
      case NutrientKey.carbs:
        return (min: 50, max: 500, step: 10);
      case NutrientKey.fat:
        return (min: 20, max: 200, step: 5);
      case NutrientKey.fiber:
        return (min: 10, max: 80, step: 1);
      case NutrientKey.sugar:
        return (min: 10, max: 150, step: 1);
      case NutrientKey.sodium:
        return (min: 500, max: 5000, step: 50);
    }
  }

  Future<void> wellnessAction(
    WellnessAction action,
    BuildContext context,
  ) async {
    switch (action) {
      case WellnessAction.goToChangePassword:
        Navigator.pushNamed(context, '/change_password');
        break;

      case WellnessAction.logout:
        try {
          // Sign out + clear Remember Me preference
          await UserModel.logout();

          // Clear login fields if we are forcing fresh login.
          // (If user toggled Remember Me OFF, they shouldn't see saved creds.)
          final loginVm = context.read<LoginViewModel>();
          loginVm.resetForLoggedOut(clearEmail: true);
        } catch (_) {
          // ignore: logout should still navigate
        }

        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        break;
    }
  }

  void updateGender(String? value) {
    if (value == null) return;
    gender = value;
    notifyListeners();
  }

  void updateName(String value) {
    nameController.text = value;
    notifyListeners();
  }

  void updateAge(int value) {
    ageController.text = value.toString();
    notifyListeners();
  }

  void updateHeight(double value) {
    heightController.text = value.toString();
    notifyListeners();
  }

  void updateWeight(double value) {
    weightController.text = value.toString();
    notifyListeners();
  }

  void displayMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void displayError(BuildContext context, String error) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: $error')));
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }
}
