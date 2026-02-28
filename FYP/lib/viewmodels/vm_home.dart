import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/food_item_model.dart';

enum FoodRecognitionAction { takePhoto, uploadImage, analyze }

class HomeViewModel extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  XFile? capturedImage;
  bool isAnalyzing = false;
  List<FoodItemModel> lastResults = [];

  /// Universal function for home actions
  Future<void> foodRecognition(
    FoodRecognitionAction action,
    BuildContext context,
  ) async {
    switch (action) {
      case FoodRecognitionAction.takePhoto:
        capturedImage = await _picker.pickImage(source: ImageSource.camera);
        notifyListeners();
        break;

      case FoodRecognitionAction.uploadImage:
        capturedImage = await _picker.pickImage(source: ImageSource.gallery);
        notifyListeners();
        break;

      case FoodRecognitionAction.analyze:
        await _handleAnalyze(context);
        break;
    }
  }

  Future<void> _handleAnalyze(BuildContext context) async {
    isAnalyzing = true;
    notifyListeners();

    try {
      lastResults = await FoodItemModel.analyzeImage(capturedImage?.path ?? '');
      if (!context.mounted) return;
      directToResult(context);
    } catch (e) {
      if (context.mounted) {
        displayError(context, 'Analyze failed: $e');
      }
    } finally {
      isAnalyzing = false;
      notifyListeners();
    }
  }

  void directToResult(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/insight',
      arguments: {
        'imagePath': capturedImage?.path,
        'results': lastResults,
      },
    );
  }

  void displayError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
