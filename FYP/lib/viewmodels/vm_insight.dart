import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import '../models/food_item_model.dart';
import '../models/meal_model.dart';
import '../data/nutrient_data.dart';

class InsightViewModel extends ChangeNotifier {
  String? imagePath;
  List<FoodItemModel> results = [];
  // Multi-selection state
  final Set<String> _selectedItemNames = {};

  // Custom user-adjusted grams for selected items
  final Map<String, double> _editedGrams = {};

  bool showEstimationView = false;
  bool isSaving = false;

  bool isSelected(FoodItemModel item) => _selectedItemNames.contains(item.name);

  // Computed property for selected FoodItemModels with calories and macros populated
  List<FoodItemModel> get selectedItems {
    return results
        .where((item) => _selectedItemNames.contains(item.name))
        .map((item) {
      final nutInfo = nutrientDatabase[item.name];

      // Determine the grams to use: edited by user, or estimated by backend, or default to 100g
      double currentGrams =
          _editedGrams[item.name] ?? item.estimatedGrams ?? 100.0;
      double ratio = currentGrams / 100.0;

      double? estimatedCals;
      if (_editedGrams.containsKey(item.name) && nutInfo != null) {
        estimatedCals = nutInfo.calories * ratio;
      } else {
        // If not edited, use the precise backend string, or fallback to nutrient DB scaled
        estimatedCals = item.calories ??
            (nutInfo?.calories != null ? nutInfo!.calories * ratio : null);
      }

      double? estimatedPro =
          nutInfo != null ? nutInfo.protein * ratio : item.protein;
      double? estimatedFat = nutInfo != null ? nutInfo.fat * ratio : item.fat;
      double? estimatedCarbs =
          nutInfo != null ? nutInfo.carbs * ratio : item.carbs;
      double? estimatedFiber =
          nutInfo != null ? nutInfo.fiber * ratio : item.fiber;
      double? estimatedSugar =
          nutInfo != null ? nutInfo.sugar * ratio : item.sugar;
      double? estimatedSodium =
          nutInfo != null ? nutInfo.sodium * ratio : item.sodium;

      // Make sure we pass along the estimatedGrams from the backend
      return item.copyWith(
        calories: estimatedCals,
        protein: estimatedPro,
        fat: estimatedFat,
        carbs: estimatedCarbs,
        fiber: estimatedFiber,
        sugar: estimatedSugar,
        sodium: estimatedSodium,
        estimatedGrams: currentGrams,
        setCaloriesNull: estimatedCals == null,
      );
    }).toList();
  }

  double get totalCalories {
    return selectedItems.fold(0.0, (sum, item) => sum + (item.calories ?? 0.0));
  }

  void updateGrams(String itemName, double grams) {
    if (grams < 0) grams = 0;
    _editedGrams[itemName] = grams;
    notifyListeners();
  }

  void loadFromArguments(Object? args) {
    if (args is Map) {
      imagePath = args['imagePath'] as String?;
      final r = args['results'];
      if (r is List<FoodItemModel>) {
        // Filter out items with 0 confidence
        var filteredList = r.where((item) {
          final double conf = double.tryParse(item.confidence) ?? 0.0;
          return conf > 0;
        }).toList();

        // Group by name and pick the one with highest confidence
        final Map<String, FoodItemModel> uniqueItems = {};
        for (final item in filteredList) {
          final existing = uniqueItems[item.name];
          if (existing == null) {
            uniqueItems[item.name] = item;
          } else {
            // Compare confidence
            final double currentConf = double.tryParse(item.confidence) ?? 0.0;
            final double existingConf =
                double.tryParse(existing.confidence) ?? 0.0;
            if (currentConf > existingConf) {
              uniqueItems[item.name] = item;
            }
          }
        }

        results = uniqueItems.values.toList();

        // Default select all
        _selectedItemNames.clear();
        for (var item in results) {
          _selectedItemNames.add(item.name);
        }
        showEstimationView = false;
      }
    }
    notifyListeners();
  }

  void toggleItemSelection(FoodItemModel item) {
    if (_selectedItemNames.contains(item.name)) {
      _selectedItemNames.remove(item.name);
    } else {
      _selectedItemNames.add(item.name);
    }
    notifyListeners();
  }

  void confirmSelection() {
    if (_selectedItemNames.isEmpty) return;
    showEstimationView = true;
    notifyListeners();
  }

  void resetSelection() {
    showEstimationView = false;
    // Optional: clear selection? Or keep it?
    // _selectedItemNames.clear();
    notifyListeners();
  }

  Future<void> saveToHistory(BuildContext context) async {
    final itemsToSave = selectedItems;
    if (itemsToSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items selected to save!')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save.')),
      );
      return;
    }

    // Capture data needed for background save
    final userId = user.uid;
    final totalCals = totalCalories;

    // Optimistic UI Update: Verify success locally and reset UI immediately
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to History!')),
      );
      resetSelection();
      // Optionally go back or clear state
      // Navigator.pop(context);
    }

    // Perform actual save in background (Fire-and-forget)
    // We don't await this so the UI is not blocked
    try {
      final meal = MealModel(
        id: '', // Firestore will generate ID
        dateTime: DateTime.now(),
        items: itemsToSave,
        totalCalories: totalCals,
        imageUrl: null,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('history')
          .add(meal.toJson());

      // Success - no further UI action needed as we already told the user it's saved
    } catch (e) {
      // In a real app, you might want to show a toast or retry,
      // but for now we just log it as it's an optimistic save failure.
      debugPrint("Error saving to history in background: $e");
    }
  }
}
