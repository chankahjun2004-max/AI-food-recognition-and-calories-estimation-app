import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../viewmodels/vm_mealdetail.dart';

import '../models/food_item_model.dart';

class MealDetailView extends StatelessWidget {
  const MealDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MealDetailViewModel>();
    final cs = Theme.of(context).colorScheme;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (vm.meal == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.loadFromArguments(args);
      });
    }

    final meal = vm.meal;

    if (meal == null) {
      return Scaffold(
        appBar: AppBar(title: Text("meal_detail_title".tr())),
        body: Center(
          child: Text("no_meal_selected".tr(), style: const TextStyle(fontSize: 16)),
        ),
      );
    }

    double totalProtein = 0;
    double totalFat = 0;
    double totalCarbs = 0;
    double totalFiber = 0;
    double totalSugar = 0;
    double totalSodium = 0;

    for (var item in meal.items) {
      totalProtein += item.protein ?? 0;
      totalFat += item.fat ?? 0;
      totalCarbs += item.carbs ?? 0;
      totalFiber += item.fiber ?? 0;
      totalSugar += item.sugar ?? 0;
      totalSodium += item.sodium ?? 0;
    }

    final hasImage = meal.imageUrl != null && meal.imageUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: hasImage ? 320.0 : kToolbarHeight + 20,
            pinned: true,
            stretch: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "meal_detail_title".tr(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              titlePadding: const EdgeInsets.only(left: 48, bottom: 16), // space for back button
              background: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          meal.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderImage(),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ],
                    )
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.primary,
                            cs.secondary,
                          ],
                        ),
                      ),
                    ),
            ),
            actions: [
              if (vm.isDeleting)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => vm.deleteMeal(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.dateTime.toLocal().toString().replaceAll(".000", ""),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${meal.totalCalories.toInt()} ${'k_cal'.tr()}",
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .primary, // Using primary color instead of hardcoded blue
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "macronutrients_title".tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _macroBadge('protein_label'.tr(), totalProtein, Colors.red),
                      _macroBadge('fat_label'.tr(), totalFat, Colors.orange),
                      _macroBadge('carbs_label'.tr(), totalCarbs, Colors.blue),
                      _macroBadge('fiber_label'.tr(), totalFiber, Colors.green),
                      _macroBadge('sugar_label'.tr(), totalSugar, Colors.purple),
                      _macroBadge('sodium_label'.tr(), totalSodium, Colors.teal, suffix: "mg"),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "items_title".tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final FoodItemModel item = meal.items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.name.tr(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (item.calories != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "${item.calories!.toStringAsFixed(0)} ${'k_cal'.tr()}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Builder(
                            builder: (context) {
                              final statusText = item.status == 'Detected' ? 'detected_status'.tr() : item.status;
                              return Text(
                                "$statusText${item.estimatedGrams != null ? ' • ${item.estimatedGrams!.toStringAsFixed(0)}g' : ''}",
                                style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _macroBadge('protein_label'.tr(), item.protein, Colors.red),
                              _macroBadge('fat_label'.tr(), item.fat, Colors.orange),
                              _macroBadge('carbs_label'.tr(), item.carbs, Colors.blue),
                              _macroBadge('fiber_label'.tr(), item.fiber, Colors.green),
                              _macroBadge('sugar_label'.tr(), item.sugar, Colors.purple),
                              _macroBadge('sodium_label'.tr(), item.sodium, Colors.teal, suffix: "mg"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: meal.items.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _macroBadge(String label, double? value, Color color, {String suffix = "g"}) {
    if (value == null || value == 0) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color.withOpacity(0.8), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            "${value.toStringAsFixed(1)}$suffix",
            style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: Colors.grey.withOpacity(0.2),
      child: const Center(
        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
      ),
    );
  }
}
