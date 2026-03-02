import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/vm_mealdetail.dart';

import '../models/food_item_model.dart';

class MealDetailView extends StatelessWidget {
  const MealDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MealDetailViewModel>();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (vm.meal == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.loadFromArguments(args);
      });
    }

    final meal = vm.meal;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal Detail"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        actions: [
          if (vm.isDeleting)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => vm.deleteMeal(context),
            ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: meal == null
          ? const Center(
              child: Text(
                "No meal selected.",
                style: TextStyle(fontSize: 16),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (meal.imageUrl != null && meal.imageUrl!.isNotEmpty)
                    Container(
                      height: 250,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          meal.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image,
                                size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  Text(
                    meal.dateTime.toLocal().toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7) ??
                          Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Total: ${meal.totalCalories.toStringAsFixed(0)} kcal",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Items",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: meal.items.length,
                      itemBuilder: (context, index) {
                        final FoodItemModel item = meal.items[index];
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                              "${item.status}${item.estimatedGrams != null ? ' • ${item.estimatedGrams!.toStringAsFixed(0)}g' : ''}"),
                          trailing: item.calories == null
                              ? null
                              : Text(
                                  "${item.calories!.toStringAsFixed(0)} kcal",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
