import 'package:flutter_test/flutter_test.dart';
import 'package:food_recognition_app/models/food_item_model.dart';

void main() {
  group('FoodItemModel Tests', () {
    test('Initialization works correctly', () {
      const food = FoodItemModel(
        name: 'Apple',
        confidence: 'High',
        status: 'Detected',
        calories: 95.0,
        protein: 0.5,
        fat: 0.3,
        carbs: 25.0,
      );

      expect(food.name, 'Apple');
      expect(food.confidence, 'High');
      expect(food.status, 'Detected');
      expect(food.calories, 95.0);
      expect(food.protein, 0.5);
      expect(food.fat, 0.3);
      expect(food.carbs, 25.0);
    });

    test('copyWith works correctly', () {
      const food = FoodItemModel(
        name: 'Apple',
        confidence: 'High',
        status: 'Detected',
        calories: 95.0,
        protein: 0.5,
        fat: 0.3,
        carbs: 25.0,
      );

      final updatedFood = food.copyWith(
          name: 'Banana', calories: 105.0, protein: 1.2, fat: 0.4, carbs: 27.0);

      expect(updatedFood.name, 'Banana');
      expect(updatedFood.confidence, 'High'); // Unchanged
      expect(updatedFood.status, 'Detected'); // Unchanged
      expect(updatedFood.calories, 105.0);
      expect(updatedFood.protein, 1.2);
      expect(updatedFood.fat, 0.4);
      expect(updatedFood.carbs, 27.0);

      // Test setting calories to null
      final nullCaloriesFood = food.copyWith(setCaloriesNull: true);
      expect(nullCaloriesFood.calories, null);
    });

    test('fromJson works correctly', () {
      final json = {
        'name': 'Orange',
        'confidence': '0.92',
        'status': 'Verified',
        'calories': 62.0,
        'protein': 1.2,
        'fat': 0.2,
        'carbs': 15.4,
      };

      final food = FoodItemModel.fromJson(json);

      expect(food.name, 'Orange');
      expect(food.confidence, '0.92');
      expect(food.status, 'Verified');
      expect(food.calories, 62.0);
      expect(food.protein, 1.2);
      expect(food.fat, 0.2);
      expect(food.carbs, 15.4);
    });

    test('toJson works correctly', () {
      const food = FoodItemModel(
        name: 'Grape',
        confidence: '0.85',
        status: 'Uncertain',
        calories: 10.0,
        protein: 0.1,
        fat: 0.1,
        carbs: 2.0,
      );

      final json = food.toJson();

      expect(json['name'], 'Grape');
      expect(json['confidence'], '0.85');
      expect(json['status'], 'Uncertain');
      expect(json['calories'], 10.0);
      expect(json['protein'], 0.1);
      expect(json['fat'], 0.1);
      expect(json['carbs'], 2.0);
    });

    test('Equality operator and hashCode work correctly', () {
      const food1 = FoodItemModel(
        name: 'Apple',
        confidence: 'High',
        status: 'Detected',
        calories: 95.0,
        protein: 0.5,
        fat: 0.3,
        carbs: 25.0,
      );

      const food2 = FoodItemModel(
        name: 'Apple',
        confidence: 'High',
        status: 'Detected',
        calories: 95.0,
        protein: 0.5,
        fat: 0.3,
        carbs: 25.0,
      );

      const food3 = FoodItemModel(
        name: 'Banana',
        confidence: 'High',
        status: 'Detected',
        calories: 95.0,
        protein: 1.2,
        fat: 0.4,
        carbs: 27.0,
      );

      expect(food1, equals(food2));
      expect(food1.hashCode, equals(food2.hashCode));
      expect(food1, isNot(equals(food3)));
      expect(food1.hashCode, isNot(equals(food3.hashCode)));
    });
  });
}
