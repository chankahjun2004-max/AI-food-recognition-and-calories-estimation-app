import 'package:flutter_test/flutter_test.dart';
import 'package:food_recognition_app/models/food_item_model.dart';
import 'package:food_recognition_app/models/meal_model.dart';

void main() {
  group('MealModel Tests', () {
    final testDate = DateTime.utc(2026, 1, 1, 12, 0);

    final sampleItems = [
      FoodItemModel(
        name: 'Chicken Rice',
        confidence: '0.95',
        status: 'Detected',
        calories: 500.0,
      ),
    ];

    test('Initialization works correctly', () {
      final meal = MealModel(
        id: 'meal_1',
        dateTime: testDate,
        items: sampleItems,
        totalCalories: 500.0,
        imageUrl: 'http://example.com/image.png',
      );

      expect(meal.id, 'meal_1');
      expect(meal.dateTime, testDate);
      expect(meal.items.length, 1);
      expect(meal.items.first.name, 'Chicken Rice');
      expect(meal.totalCalories, 500.0);
      expect(meal.imageUrl, 'http://example.com/image.png');
    });

    test('copyWith works correctly', () {
      final meal = MealModel(
        id: 'meal_1',
        dateTime: testDate,
        items: sampleItems,
        totalCalories: 500.0,
      );

      final updatedMeal = meal.copyWith(
        id: 'meal_2',
        totalCalories: 600.0,
      );

      expect(updatedMeal.id, 'meal_2');
      expect(updatedMeal.dateTime, testDate); // Unchanged
      expect(updatedMeal.items, sampleItems); // Unchanged
      expect(updatedMeal.totalCalories, 600.0);
      expect(updatedMeal.imageUrl, null); // Unchanged
    });

    test('fromJson works correctly', () {
      final json = {
        'id': 'test_id',
        'dateTime': testDate.toIso8601String(),
        'items': [
          {
            'name': 'Salad',
            'confidence': '0.98',
            'status': 'Detected',
            'calories': 150.0,
          }
        ],
        'totalCalories': 150.0,
        'imageUrl': 'http://image.com/salad.png',
      };

      final meal = MealModel.fromJson(json);

      expect(meal.id, 'test_id');
      expect(meal.dateTime, testDate);
      expect(meal.items.length, 1);
      expect(meal.items.first.name, 'Salad');
      expect(meal.items.first.calories, 150.0);
      expect(meal.totalCalories, 150.0);
      expect(meal.imageUrl, 'http://image.com/salad.png');
    });

    test('toJson works correctly', () {
      final meal = MealModel(
        id: 'test_id',
        dateTime: testDate,
        items: sampleItems,
        totalCalories: 500.0,
      );

      final json = meal.toJson();

      expect(json['id'], 'test_id');
      expect(json['dateTime'], testDate.toIso8601String());
      expect(json['totalCalories'], 500.0);
      expect((json['items'] as List).length, 1);
      expect((json['items'] as List).first['name'], 'Chicken Rice');
      expect(json['imageUrl'], null);
    });

    test('Equality operator and hashCode work correctly', () {
      final meal1 = MealModel(
        id: 'm1',
        dateTime: testDate,
        items: sampleItems,
        totalCalories: 500.0,
      );

      final meal2 = MealModel(
        id: 'm1',
        dateTime: testDate,
        items: sampleItems, // identical list instances since they're const/same
        totalCalories: 500.0,
      );

      final meal3 = MealModel(
        id: 'm2',
        dateTime: testDate,
        items: sampleItems,
        totalCalories: 600.0,
      );

      expect(meal1, equals(meal2));
      expect(meal1.hashCode, equals(meal2.hashCode));
      expect(meal1, isNot(equals(meal3)));
      expect(meal1.hashCode, isNot(equals(meal3.hashCode)));
    });
  });
}
