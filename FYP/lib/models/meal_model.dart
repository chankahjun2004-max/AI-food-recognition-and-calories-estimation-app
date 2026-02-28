import 'food_item_model.dart';

class MealModel {
  final String id;
  final DateTime dateTime;
  final List<FoodItemModel> items;
  final double totalCalories;
  final String? imageUrl;

  const MealModel({
    required this.id,
    required this.dateTime,
    required this.items,
    required this.totalCalories,
    this.imageUrl,
  });

  MealModel copyWith({
    String? id,
    DateTime? dateTime,
    List<FoodItemModel>? items,
    double? totalCalories,
    String? imageUrl,
  }) {
    return MealModel(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      items: items ?? this.items,
      totalCalories: totalCalories ?? this.totalCalories,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory MealModel.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? const [];
    return MealModel(
      id: (json['id'] ?? '').toString(),
      dateTime: DateTime.tryParse((json['dateTime'] ?? '').toString()) ??
          DateTime.now(),
      items: rawItems
          .map((e) =>
              FoodItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'totalCalories': totalCalories,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() =>
      'MealModel(id: $id, dateTime: $dateTime, items: ${items.length}, totalCalories: $totalCalories, imageUrl: $imageUrl)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is MealModel &&
            other.id == id &&
            other.dateTime == dateTime &&
            _listEquals(other.items, items) &&
            other.totalCalories == totalCalories &&
            other.imageUrl == imageUrl);
  }

  @override
  int get hashCode =>
      Object.hash(id, dateTime, Object.hashAll(items), totalCalories, imageUrl);

  static bool _listEquals(List<FoodItemModel> a, List<FoodItemModel> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // -- Other Methods from UML --
  void connect() {
    // TODO: Implement connect
  }

  void close() {
    // TODO: Implement close
  }
}
