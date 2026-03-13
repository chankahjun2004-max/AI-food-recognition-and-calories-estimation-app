import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
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
        title: Text(
          'insight_title'.tr(),
          style:
              TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        Text(
                          'detected_items_title'.tr(),
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'select_items_hint'.tr(),
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                                Text(
                                  'no_items_detected'.tr(),
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'clearer_photo_hint'.tr(),
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        else
                          ...vm.results
                              .map((item) => _buildItemTile(context, item, vm))
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
                        child: Text(
                          'confirm_estimate_button'.tr(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildItemTile(
      BuildContext context, FoodItemModel item, InsightViewModel vm) {
    final isSelected = vm.isSelected(item);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: isSelected
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Conf: ${((double.tryParse(item.confidence) ?? 0) * 100).toStringAsFixed(0)}%",
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
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
          Text(
            'calorie_estimation_title'.tr(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Selected Items List
          ...selectedItems.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D62ED),
                            ),
                          ),
                        ),
                        Text(
                          item.calories != null
                              ? "${item.calories!.toStringAsFixed(0)} kcal"
                              : "N/A kcal",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('weight_label'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                          onPressed: () => vm.updateGrams(
                              item.name, (item.estimatedGrams ?? 100) - 10),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Expanded(
                          child: Slider(
                            value:
                                (item.estimatedGrams ?? 100).clamp(0.0, 1000.0),
                            min: 0,
                            max: 1000,
                            divisions: 100,
                            activeColor: const Color(0xFF2D62ED),
                            inactiveColor: Colors.grey.shade300,
                            onChanged: (value) =>
                                vm.updateGrams(item.name, value),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline,
                              color: Colors.green),
                          onPressed: () => vm.updateGrams(
                              item.name, (item.estimatedGrams ?? 100) + 10),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        SizedBox(
                          width: 45,
                          child: Text(
                            "${(item.estimatedGrams ?? 100).toStringAsFixed(0)}g",
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _macroBadge("Protein", item.protein, Colors.red),
                        _macroBadge("Fat", item.fat, Colors.orange),
                        _macroBadge("Carbs", item.carbs, Colors.blue),
                        _macroBadge("Fiber", item.fiber, Colors.green),
                        _macroBadge("Sugar", item.sugar, Colors.purple),
                        _macroBadge("Sodium", item.sodium, Colors.teal,
                            suffix: "mg"),
                      ],
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
                Text(
                  'total_estimated_label'.tr(),
                  style: const TextStyle(
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
                  child: Text('back_cancel_button'.tr()),
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
                  label: Text(vm.isSaving ? 'saving_label'.tr() : 'save_result_button'.tr()),
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

  Widget _macroBadge(String label, double? value, Color color,
      {String suffix = "g"}) {
    if (value == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        "$label: ${value.toStringAsFixed(1)}$suffix",
        style:
            TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  static Widget _placeholderImage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            'no_image_provided'.tr(),
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
