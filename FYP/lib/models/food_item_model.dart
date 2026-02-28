import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodItemModel {
  final String name;

  /// e.g. "High", "Medium", "Low"
  final String confidence;

  /// e.g. "Detected", "Low", "Uncertain"
  final String status;

  /// Optional per-item calorie estimate (kcal)
  final double? calories;
  final double? protein;
  final double? fat;
  final double? carbs;

  const FoodItemModel({
    required this.name,
    required this.confidence,
    required this.status,
    this.calories,
    this.protein,
    this.fat,
    this.carbs,
  });

  FoodItemModel copyWith({
    String? name,
    String? confidence,
    String? status,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
    bool setCaloriesNull = false,
  }) {
    return FoodItemModel(
      name: name ?? this.name,
      confidence: confidence ?? this.confidence,
      status: status ?? this.status,
      calories: setCaloriesNull ? null : (calories ?? this.calories),
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
    );
  }

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    final c = json['calories'];
    final p = json['protein'];
    final f = json['fat'];
    final cb = json['carbs'];
    return FoodItemModel(
      name: (json['name'] ?? '').toString(),
      confidence: (json['confidence'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      calories: c == null ? null : (c as num).toDouble(),
      protein: p == null ? null : (p as num).toDouble(),
      fat: f == null ? null : (f as num).toDouble(),
      carbs: cb == null ? null : (cb as num).toDouble(),
    );
  }

  // Used for persisting offline or Firebase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'confidence': confidence,
      'status': status,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
    };
  }

  @override
  String toString() =>
      'FoodItemModel(name: $name, confidence: $confidence, status: $status, calories: $calories, protein: $protein, fat: $fat, carbs: $carbs)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is FoodItemModel &&
            other.name == name &&
            other.confidence == confidence &&
            other.status == status &&
            other.calories == calories &&
            other.protein == protein &&
            other.fat == fat &&
            other.carbs == carbs);
  }

  @override
  int get hashCode =>
      Object.hash(name, confidence, status, calories, protein, fat, carbs);

  // -- Business Logic / Service Methods --

  /// Stub implementation for development/testing - previously in FoodAIService.
  ///
  /// Replace with your actual ML inference pipeline (e.g., TFLite/YOLO),
  /// and return detected items as [FoodItemModel]s.
  static Future<List<FoodItemModel>> analyzeImage(String imagePath) async {
    if (imagePath.isEmpty) return [];

    try {
      final uri = Uri.parse(
          'https://backend-597587756390.asia-southeast1.run.app/predict');
      final request = http.MultipartRequest('POST', uri);

      print('[FoodItemModel] Uploading image: $imagePath');
      // Add the image file
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('[FoodItemModel] Response Status: ${response.statusCode}');
      print('[FoodItemModel] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;

        if (decoded.containsKey('detections')) {
          final detections = decoded['detections'] as List;
          print('[FoodItemModel] Found ${detections.length} detections.');
          return detections
              .map((d) => FoodItemModel(
                    name: d['class'] ?? 'Unknown',
                    confidence:
                        (d['confidence'] as num?)?.toStringAsFixed(2) ?? '0.00',
                    status: 'Detected',
                    calories: null,
                    protein: null,
                    fat: null,
                    carbs: null,
                  ))
              .toList();
        }

        if (decoded.containsKey('predictions')) {
          final preds = decoded['predictions'] as List;
          print(
              '[FoodItemModel] Found ${preds.length} predictions (alt format).');
          return preds
              .map((p) => FoodItemModel(
                    name: p['class'] ?? 'Unknown',
                    confidence:
                        (p['confidence'] as num?)?.toStringAsFixed(2) ?? '0.00',
                    status:
                        'Detected', // You might calculate this based on confidence(change to accuracy) threshold
                    calories: null, // Backend doesn't provide calories yet
                    protein: null,
                    fat: null,
                    carbs: null,
                  ))
              .toList();
        } else {
          // Fallback if direct object
          print('[FoodItemModel] Falling back to direct object parse.');
          return [
            FoodItemModel(
              name: decoded['class'] ?? 'Unknown',
              confidence:
                  (decoded['confidence'] as num?)?.toStringAsFixed(2) ?? '0.00',
              status: 'Detected',
              calories: null,
              protein: null,
              fat: null,
              carbs: null,
            )
          ];
        }
      } else {
        throw 'Server error: ${response.statusCode} ${response.body}';
      }
    } catch (e) {
      print('[FoodItemModel] Error: $e');
      throw 'Analyze failed: $e';
    }
  }

  /// Stub predict method from UML
  static Future<void> predict(String imagePath) async {
    // TODO: any specific prediction logic distinct from analyzeImage
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // -- Other Methods from UML --
  void connect() {
    // TODO: Implement connect
  }

  void close() {
    // TODO: Implement close
  }
}
