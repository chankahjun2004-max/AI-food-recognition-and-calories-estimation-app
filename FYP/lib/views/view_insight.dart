import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/vm_insight.dart';
import '../models/food_item_model.dart';

class InsightView extends StatelessWidget {
  const InsightView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InsightViewModel>();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      final argPath = args['imagePath'] as String?;
      // Reload if we have a path and it differs from current state,
      // OR if we have results in args that we want to force display.
      // Usually just checking path difference is enough for a unique photo.
      if (argPath != null && argPath != vm.imagePath) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          vm.loadFromArguments(args);
        });
      } else if (vm.imagePath == null) {
        // Fallback: if VM is empty but we have args (maybe just results?), load them.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          vm.loadFromArguments(args);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Insight",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF6FDF6),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: vm.showEstimationView
            ? _buildCalorieEstimationView(context, vm)
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.green.shade100),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: vm.imagePath == null
                                ? _placeholderImage()
                                : Image.file(
                                    File(vm.imagePath!),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Detected Items",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Select items to estimate calories",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        if (vm.results.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                const Icon(Icons.info_outline,
                                    size: 40, color: Colors.grey),
                                const SizedBox(height: 10),
                                const Text(
                                  "No items detected.",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  "Try taking a clearer photo.",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        else
                          ...vm.results
                              .map((item) => _buildItemTile(item, vm))
                              .toList(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  if (vm.results.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                      child: ElevatedButton(
                        onPressed: vm.confirmSelection,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: const Color(0xFF2D62ED),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Confirm & Estimate",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildItemTile(FoodItemModel item, InsightViewModel vm) {
    final isSelected = vm.isSelected(item);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isSelected
            ? Border.all(color: const Color(0xFF2D62ED), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 7,
          ),
        ],
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (_) => vm.toggleItemSelection(item),
        title: Text(
          item.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          "Conf: ${((double.tryParse(item.confidence) ?? 0) * 100).toStringAsFixed(0)}%",
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        activeColor: const Color(0xFF2D62ED),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      ),
    );
  }

  Widget _buildCalorieEstimationView(
      BuildContext context, InsightViewModel vm) {
    final selectedItems = vm.selectedItems;
    final totalCalories = vm.totalCalories;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Re-display image or just a header
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: vm.imagePath == null
                  ? _placeholderImage()
                  : Image.file(
                      File(vm.imagePath!),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Calorie Estimation",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Selected Items List
          ...selectedItems.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D62ED),
                      ),
                    ),
                    Text(
                      "${item.calories?.toStringAsFixed(0) ?? 'N/A'} kcal",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 10),
          // Total Calories
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Estimated:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  "${totalCalories.toStringAsFixed(0)} kcal",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: vm.resetSelection,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                  ),
                  child: const Text("Back / Cancel"),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      vm.isSaving ? null : () => vm.saveToHistory(context),
                  icon: vm.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check),
                  label: Text(vm.isSaving ? 'Saving...' : 'Save Result'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF2D62ED),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  static Widget _placeholderImage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            "No image provided",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
