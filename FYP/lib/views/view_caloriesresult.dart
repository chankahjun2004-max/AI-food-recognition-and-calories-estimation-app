import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/vm_calorieresult.dart';
class CalorieResultView extends StatefulWidget {
  final String? imagePath;
  const CalorieResultView({super.key, this.imagePath});

  @override
  State<CalorieResultView> createState() => _CalorieResultViewState();
}

class _CalorieResultViewState extends State<CalorieResultView> {
  // Mock data representing detected items from AI
  final List<Map<String, dynamic>> detectedItems = [
    {'name': 'Rice', 'grams': 150.0, 'kcal': 200},
    {'name': 'Fried Chicken', 'grams': 120.0, 'kcal': 300},
    {'name': 'Sambal', 'grams': 30.0, 'kcal': 50},
  ];

  // Calculate total automatically
  int get totalCalories => detectedItems.fold(0, (sum, item) => sum + (item['kcal'] as int));

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CalorieResultViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detected Calories', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => vm.calorieAction(CalorieAction.goBack, context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Food Image
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: widget.imagePath != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(File(widget.imagePath!), fit: BoxFit.cover),
              )
                  : const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
            ),
            const SizedBox(height: 25),

            // 2. Header
            const Text(
              "AI Detected Portions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Based on standard Malaysian serving sizes",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 15),

            // 3. Static List of Items (No Sliders)
            ...detectedItems.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Blue indicator line
                        Container(
                          width: 4,
                          height: 35,
                          decoration: BoxDecoration(
                              color: const Color(0xFF2D62ED),
                              borderRadius: BorderRadius.circular(2)
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Name and Grams
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                item['name'],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
                            ),
                            const SizedBox(height: 4),
                            Text(
                                '${item['grams'].round()}g',
                                style: const TextStyle(color: Colors.grey, fontSize: 13)
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Calorie Count
                    Text(
                        '${item['kcal']} Kcal',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            // 4. Total Summary Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF), // Light blue background
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Calories", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    "$totalCalories Kcal",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D62ED)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 5. Confirm Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  vm.calorieAction(CalorieAction.confirmAndSave, context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D62ED),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 2,
                ),
                child: const Text("Confirm & Save", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}