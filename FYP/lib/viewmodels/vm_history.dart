import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../models/meal_model.dart';

enum HistoryAction {
  openMealDetail,
  pickDate,
  previousDay,
  nextDay,
}

class HistoryViewModel extends ChangeNotifier {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static FirebaseFirestore _db = FirebaseFirestore.instance;

  @visibleForTesting
  static void setMockInstances(
      FirebaseAuth mockAuth, FirebaseFirestore mockDb) {
    _auth = mockAuth;
    _db = mockDb;
  }

  // State: The currently selected date (Default to Now)
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  bool isLoading = false;

  // Master list of all history (Fetched from Firestore)
  final List<MealModel> _allHistory = [];

  // Getters for UI
  List<MealModel> get currentDayMeals {
    return _allHistory
        .where((meal) => _isSameDay(meal.dateTime, _selectedDate))
        .toList();
  }

  int get totalDailyCalories {
    return currentDayMeals.fold(
        0, (sum, meal) => sum + meal.totalCalories.toInt());
  }

  /// Constructor: Load real data
  HistoryViewModel() {
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      _allHistory.clear();
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .orderBy('dateTime', descending: true)
          .get();

      _allHistory.clear();
      for (var doc in snapshot.docs) {
        // We ensure the ID from the doc is part of the model if needed,
        // though our model has an ID field we can override or use doc.id.
        // For now, let's assume the stored ID inside the JSON is correct or empty.
        // We can patch it with doc.id.
        var data = doc.data();
        data['id'] = doc.id;
        _allHistory.add(MealModel.fromJson(data));
      }
    } catch (e) {
      print("Error fetching history: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- Actions ---

  Future<void> historyAction(
    HistoryAction action,
    BuildContext context, {
    dynamic data,
  }) async {
    switch (action) {
      case HistoryAction.openMealDetail:
        if (data is MealModel) {
          Navigator.pushNamed(context, '/meal_detail', arguments: data);
        }
        break;

      case HistoryAction.previousDay:
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
        notifyListeners();
        break;

      case HistoryAction.nextDay:
        _selectedDate = _selectedDate.add(const Duration(days: 1));
        notifyListeners();
        break;

      case HistoryAction.pickDate:
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF2D62ED), // Blue color from your image
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null && picked != _selectedDate) {
          _selectedDate = picked;
          notifyListeners();
        }
        break;
    }
  }

  // --- Helpers ---

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // _loadMockData removed

  void displayResult() {
    // TODO: Implement displayResult logic (e.g., show a dialog or new screen summary)
  }

  void displayError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $error')),
    );
  }
}
