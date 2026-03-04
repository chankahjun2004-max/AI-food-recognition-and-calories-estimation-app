import 'package:flutter/material.dart';

enum CalorieAction {
  goBack,
  confirmAndSave,
}

class CalorieResultViewModel extends ChangeNotifier {
  /// Universal function for CalorieResultView
  Future<void> calorieAction(CalorieAction action, BuildContext context) async {
    switch (action) {
      case CalorieAction.goBack:
        Navigator.pop(context);
        break;

      case CalorieAction.confirmAndSave:
        // Keep current behaviour (view uses mock items). You can integrate History saving in Batch 3.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal Logged to History!')),
        );
        Navigator.pop(context);
        break;
    }
  }

  void directToResult(BuildContext context) {
    Navigator.pushNamed(context, '/insight');
  }

  void displayError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
