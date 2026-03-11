
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../models/meal_model.dart';

class MealDetailViewModel extends ChangeNotifier {
  MealModel? meal;

  bool isDeleting = false;

  void loadFromArguments(Object? args) {
    if (args is MealModel) {
      meal = args;
      notifyListeners();
    }
  }

  Future<void> deleteMeal(BuildContext context) async {
    if (meal == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to delete.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text('Are you sure you want to delete this meal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isDeleting = true;
    notifyListeners();

    try {
      meal!.connect();
      // 1. Delete from Firestore
      await meal!.db
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .doc(meal!.id)
          .delete();

      // 2. Delete Image from Storage if exists
      if (meal!.imageUrl != null && meal!.imageUrl!.isNotEmpty) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(meal!.imageUrl!);
          await ref.delete();
        } catch (e) {
          debugPrint("Error deleting image: $e");
          // Continue even if image delete fails (maybe already deleted)
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal deleted')),
        );
        Navigator.pop(context); // Go back to history list
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e')),
        );
      }
    } finally {
      meal?.close();
      isDeleting = false;
      notifyListeners();
    }
  }
}
