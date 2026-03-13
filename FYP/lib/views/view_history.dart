import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../viewmodels/vm_history.dart';
import '../models/meal_model.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // Replaced hardcoded grey background
      appBar: AppBar(
        title: Text(
          'history_page_title'.tr(),
          style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- 1. Date Navigation Header ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          size: 16, color: Colors.teal),
                      onPressed: () =>
                          vm.historyAction(HistoryAction.previousDay, context),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () =>
                          vm.historyAction(HistoryAction.pickDate, context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formatDate(vm.selectedDate),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.teal),
                      onPressed: () =>
                          vm.historyAction(HistoryAction.nextDay, context),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'total_calories'.tr(args: [vm.totalDailyCalories.toString()]),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const Divider(thickness: 1, height: 1),
          const SizedBox(height: 10),

          // --- 2. Meal List ---
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.currentDayMeals.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        itemCount: vm.currentDayMeals.length,
                        itemBuilder: (context, index) {
                          final meal = vm.currentDayMeals[index];
                          return _buildMealCard(context, vm, meal);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(
      BuildContext context, HistoryViewModel vm, MealModel meal) {
    // Helper to extract the meal name from items (assuming first item is main dish for now)
    final String mainItemName =
        meal.items.isNotEmpty ? meal.items.first.name.tr() : "unknown_meal".tr();
    final String timeString = _formatTime(meal.dateTime);

    return GestureDetector(
      onTap: () =>
          vm.historyAction(HistoryAction.openMealDetail, context, data: meal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeString, // e.g. "8:00 AM"
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    mainItemName, // e.g. "Breakfast: Roti Canai"
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                ],
              ),
            ),
            // Right Icon or Image
            if (meal.imageUrl != null && meal.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  meal.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
              )
            else
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fastfood_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'no_meals_logged'.tr(),
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Simple date formatter to avoid 'intl' package dependency for this snippet
  String _formatDate(DateTime date) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return "${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}";
  }

  String _formatTime(DateTime date) {
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? "PM" : "AM";
    final minute = date.minute.toString().padLeft(2, '0');
    return "$hour:$minute $amPm";
  }
}
