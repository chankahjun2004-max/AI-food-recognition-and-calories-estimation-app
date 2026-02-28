import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

import '../viewmodels/vm_wellnessinsight.dart';

class WellnessInsightView extends StatefulWidget {
  const WellnessInsightView({super.key});

  @override
  State<WellnessInsightView> createState() => _WellnessInsightViewState();
}

class _WellnessInsightViewState extends State<WellnessInsightView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // PROFILE: universal edit toggle + local draft controllers
  bool _isProfileEditing = false;

  late final TextEditingController _nameEditCtrl = TextEditingController();
  late final TextEditingController _ageEditCtrl = TextEditingController();
  late final TextEditingController _heightEditCtrl = TextEditingController();
  late final TextEditingController _weightEditCtrl = TextEditingController();
  String _genderEditValue = 'Male';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameEditCtrl.dispose();
    _ageEditCtrl.dispose();
    _heightEditCtrl.dispose();
    _weightEditCtrl.dispose();
    super.dispose();
  }

  PopupMenuButton<WellnessAction> _menu(WellnessInsightViewModel vm) {
    return PopupMenuButton<WellnessAction>(
      onSelected: (action) => vm.wellnessAction(action, context),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: WellnessAction.goToChangePassword,
          child: Text('Change Password'),
        ),
        PopupMenuItem(
          value: WellnessAction.logout,
          child: Text('Logout'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WellnessInsightViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: vm.bgColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: vm.bgColor,
            title: const Text(
              'Wellness',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            actions: [
              IconButton(
                onPressed: () => vm.fetchWellnessData(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
              ),
              _menu(vm),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: vm.primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    labelColor: vm.primaryColor,
                    unselectedLabelColor: Colors.black54,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                    tabs: const [
                      Tab(text: 'Insights'),
                      Tab(text: 'Profile'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildInsightsTab(context, vm),
              _buildProfileTab(context, vm),
            ],
          ),
        );
      },
    );
  }

  // ==============================
  // INSIGHTS TAB
  // ==============================
  Widget _buildInsightsTab(BuildContext context, WellnessInsightViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dailyGoalCard(context, vm),
          const SizedBox(height: 25),
          const Text(
            "Nutrition Trends",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 15),
          _trendsCard(context, vm),
          const SizedBox(height: 15),
          _nutrientBreakdownCard(context, vm),
        ],
      ),
    );
  }

  // ==============================
  // DAILY GOAL (Interactive + Color Rules)
  // ==============================
  Widget _dailyGoalCard(BuildContext context, WellnessInsightViewModel vm) {
    final calories = vm.goals[NutrientKey.calories]!;
    final ratio = calories.ratio;
    final goalColor = vm.goalColor(ratio);
    final percentForRing = ratio.clamp(0.0, 1.0);
    final exceeded = ratio > 1.0;
    final exceededBy =
        (calories.consumed - calories.target).clamp(0.0, double.infinity);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _openNutrientGoalEditor(context, vm, NutrientKey.calories),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [vm.primaryColor, vm.primaryColor.withOpacity(0.82)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: vm.primaryColor.withOpacity(0.28),
                blurRadius: 15,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Daily Goal",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${calories.consumed.toStringAsFixed(0)} / ${calories.target.toStringAsFixed(0)} ${calories.unit}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (exceeded)
                        Text(
                          "Exceeded by ${exceededBy.toStringAsFixed(0)} ${calories.unit}",
                          style: const TextStyle(
                            color: Color(0xFFFFD2D2),
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        const Text(
                          "You're on track",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  CircularPercentIndicator(
                    radius: 46.0,
                    lineWidth: 9.0,
                    percent: percentForRing,
                    center: Icon(
                      exceeded ? Icons.warning_rounded : Icons.bolt,
                      color: Colors.white,
                      size: 30,
                    ),
                    progressColor: exceeded ? Colors.redAccent : Colors.white,
                    backgroundColor: Colors.white24,
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Quick macro goals
              _miniGoalRow(vm, NutrientKey.protein),
              const SizedBox(height: 10),
              _miniGoalRow(vm, NutrientKey.carbs),
              const SizedBox(height: 10),
              _miniGoalRow(vm, NutrientKey.fat),

              const SizedBox(height: 10),
              Row(
                children: [
                  _legendDot(Colors.white),
                  const SizedBox(width: 6),
                  const Text('On track',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(width: 12),
                  _legendDot(Colors.orange),
                  const SizedBox(width: 6),
                  const Text('Near target',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(width: 12),
                  _legendDot(Colors.red),
                  const SizedBox(width: 6),
                  const Text('Exceeded',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const Spacer(),
                  Icon(Icons.info_outline,
                      color: goalColor.withOpacity(0.95), size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color c) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _miniGoalRow(WellnessInsightViewModel vm, NutrientKey key) {
    final goal = vm.goals[key]!;
    final ratio = goal.ratio;
    final pct = ratio.clamp(0.0, 1.0);
    final exceeded = ratio > 1.0;

    return Row(
      children: [
        Icon(goal.icon, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                exceeded ? Colors.redAccent : Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "${goal.consumed.toStringAsFixed(0)}/${goal.target.toStringAsFixed(0)}${goal.unit}",
          style: TextStyle(
            color: exceeded ? const Color(0xFFFFD2D2) : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          exceeded ? Icons.arrow_upward_rounded : Icons.check_circle_outline,
          color: exceeded ? const Color(0xFFFFD2D2) : Colors.white70,
          size: 16,
        ),
      ],
    );
  }

  // ==============================
  // EDIT TARGET (ANY NUTRIENT)
  // ==============================
  void _openNutrientGoalEditor(
    BuildContext context,
    WellnessInsightViewModel vm,
    NutrientKey key,
  ) {
    final goal = vm.goals[key]!;
    final bounds = vm.sliderBoundsFor(key);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        double sliderValue = goal.target.clamp(bounds.min, bounds.max);

        int divisions() {
          final range = bounds.max - bounds.min;
          final div = (range / bounds.step).round();
          return div <= 0 ? 1 : div;
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 14,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Edit ${goal.label} Target',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      )
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Target: ${sliderValue.toStringAsFixed(0)} ${goal.unit}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Slider(
                    value: sliderValue,
                    min: bounds.min,
                    max: bounds.max,
                    divisions: divisions(),
                    onChanged: (v) => setState(() => sliderValue = v),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => setState(() {
                          sliderValue = (sliderValue - bounds.step)
                              .clamp(bounds.min, bounds.max);
                        }),
                        child: Text('-${bounds.step.toStringAsFixed(0)}'),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () => setState(() {
                          sliderValue = (sliderValue + bounds.step)
                              .clamp(bounds.min, bounds.max);
                        }),
                        child: Text('+${bounds.step.toStringAsFixed(0)}'),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          vm.setNutrientTarget(key, sliderValue);
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tip: indicators turn orange near target and red when exceeded.',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==============================
  // TRENDS (axes, tooltip, nutrient selector, target line)
  // ==============================
  Widget _trendsCard(BuildContext context, WellnessInsightViewModel vm) {
    final goal = vm.selectedTrendGoal;
    final unit = goal.unit;
    final target = goal.target;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _trendChip(vm, NutrientKey.calories),
              _trendChip(vm, NutrientKey.protein),
              _trendChip(vm, NutrientKey.carbs),
              _trendChip(vm, NutrientKey.fat),
              _trendChip(vm, NutrientKey.fiber),
              _trendChip(vm, NutrientKey.sugar),
              _trendChip(vm, NutrientKey.sodium),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _niceInterval(vm.trendData),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.15),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= vm.weekLabels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            vm.weekLabels[i],
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black54),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      interval: _niceInterval(vm.trendData),
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black54),
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    tooltipRoundedRadius: 10,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((s) {
                        final idx = s.x.toInt();
                        final day = (idx >= 0 && idx < vm.weekLabels.length)
                            ? vm.weekLabels[idx]
                            : "Day";
                        return LineTooltipItem(
                          "$day\n${s.y.toStringAsFixed(0)} $unit",
                          const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        );
                      }).toList();
                    },
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: target,
                      color: Colors.orange.withOpacity(0.7),
                      strokeWidth: 2,
                      dashArray: [6, 6],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 8, bottom: 6),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.w700,
                        ),
                        labelResolver: (_) =>
                            "Target ${target.toStringAsFixed(0)}$unit",
                      ),
                    ),
                  ],
                ),
                minX: 0,
                maxX: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: vm.trendData,
                    isCurved: true,
                    color: vm.primaryColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          vm.primaryColor.withOpacity(0.22),
                          vm.primaryColor.withOpacity(0.02),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trendChip(WellnessInsightViewModel vm, NutrientKey key) {
    final goal = vm.goals[key]!;
    final selected = vm.selectedTrend == key;

    return ChoiceChip(
      label: Text(
        goal.label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: selected,
      selectedColor: vm.primaryColor.withOpacity(0.12),
      onSelected: (_) => vm.setSelectedTrend(key),
      avatar: Icon(
        goal.icon,
        size: 16,
        color: selected ? vm.primaryColor : Colors.black54,
      ),
      labelStyle: TextStyle(color: selected ? vm.primaryColor : Colors.black87),
      side: BorderSide(
        color: selected
            ? vm.primaryColor.withOpacity(0.25)
            : Colors.grey.withOpacity(0.25),
      ),
    );
  }

  double _niceInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 10;
    final ys = spots.map((e) => e.y).toList()..sort();
    final minY = ys.first;
    final maxY = ys.last;
    final range = (maxY - minY).abs();

    if (range <= 10) return 2;
    if (range <= 50) return 10;
    if (range <= 150) return 25;
    if (range <= 500) return 100;
    return (range / 5).roundToDouble().clamp(100, 1000);
  }

  // ==============================
  // NUTRIENT CONTENT (Today) + Tap to edit target
  // ==============================
  Widget _nutrientBreakdownCard(
    BuildContext context,
    WellnessInsightViewModel vm,
  ) {
    final keys = [
      NutrientKey.calories,
      NutrientKey.protein,
      NutrientKey.carbs,
      NutrientKey.fat,
      NutrientKey.fiber,
      NutrientKey.sugar,
      NutrientKey.sodium,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Nutrients",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...keys.map(
            (k) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _nutrientRow(context, vm, k),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Tip: Tap any nutrient to change its daily target.",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _nutrientRow(
    BuildContext context,
    WellnessInsightViewModel vm,
    NutrientKey key,
  ) {
    final goal = vm.goals[key]!;
    final ratio = goal.ratio;
    final color = vm.goalColor(ratio);
    final pct = ratio.clamp(0.0, 1.0);
    final exceeded = ratio > 1.0;
    final diff = (goal.target - goal.consumed);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openNutrientGoalEditor(context, vm, key),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(goal.icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.label,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          "${goal.consumed.toStringAsFixed(0)} / ${goal.target.toStringAsFixed(0)} ${goal.unit}",
                          style: TextStyle(
                            color: exceeded ? Colors.red : Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.edit_outlined,
                            size: 16, color: Colors.black38),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: Colors.grey.withOpacity(0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      exceeded
                          ? "Over by ${(goal.consumed - goal.target).toStringAsFixed(0)} ${goal.unit}"
                          : "${diff.toStringAsFixed(0)} ${goal.unit} left",
                      style: TextStyle(
                        fontSize: 12,
                        color: exceeded ? Colors.red : Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================
  // PROFILE TAB (Universal Edit Button)
  // ==============================
  Widget _buildProfileTab(BuildContext context, WellnessInsightViewModel vm) {
    // when not editing, keep draft values synced with VM
    if (!_isProfileEditing) {
      _nameEditCtrl.text = vm.nameController.text;
      _ageEditCtrl.text = vm.ageController.text;
      _heightEditCtrl.text = vm.heightController.text;
      _weightEditCtrl.text = vm.weightController.text;
      _genderEditValue = vm.gender;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Personal Information",
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                    if (!_isProfileEditing)
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isProfileEditing = true;
                            _nameEditCtrl.text = vm.nameController.text;
                            _ageEditCtrl.text = vm.ageController.text;
                            _heightEditCtrl.text = vm.heightController.text;
                            _weightEditCtrl.text = vm.weightController.text;
                            _genderEditValue = vm.gender;
                          });
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isProfileEditing = false;
                              });
                            },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              final name = _nameEditCtrl.text.trim();
                              final age =
                                  int.tryParse(_ageEditCtrl.text.trim());
                              final height =
                                  double.tryParse(_heightEditCtrl.text.trim());
                              final weight =
                                  double.tryParse(_weightEditCtrl.text.trim());

                              if (name.isEmpty) {
                                vm.displayError(
                                    context, "Name cannot be empty.");
                                return;
                              }
                              if (age == null || age <= 0) {
                                vm.displayError(
                                    context, "Please enter a valid age.");
                                return;
                              }
                              if (height == null || height <= 0) {
                                vm.displayError(
                                    context, "Please enter a valid height.");
                                return;
                              }
                              if (weight == null || weight <= 0) {
                                vm.displayError(
                                    context, "Please enter a valid weight.");
                                return;
                              }

                              vm.updateName(name);
                              vm.updateAge(age);
                              vm.updateHeight(height);
                              vm.updateWeight(weight);
                              vm.updateGender(_genderEditValue);

                              vm.displayMessage(context, "Profile updated.");

                              setState(() {
                                _isProfileEditing = false;
                              });
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                _textField(
                  label: 'Name',
                  controller: _nameEditCtrl,
                  enabled: _isProfileEditing,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _textField(
                        label: 'Age',
                        controller: _ageEditCtrl,
                        keyboardType: TextInputType.number,
                        enabled: _isProfileEditing,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _genderDropdown(
                        enabled: _isProfileEditing,
                        value: _genderEditValue,
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _genderEditValue = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _textField(
                        label: 'Height (cm)',
                        controller: _heightEditCtrl,
                        keyboardType: TextInputType.number,
                        enabled: _isProfileEditing,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _textField(
                        label: 'Weight (kg)',
                        controller: _weightEditCtrl,
                        keyboardType: TextInputType.number,
                        enabled: _isProfileEditing,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _textField(
                  label: 'Email',
                  controller: TextEditingController(text: vm.email),
                  enabled: false,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isProfileEditing
                            ? null
                            : () => vm.wellnessAction(
                                WellnessAction.goToChangePassword, context),
                        icon: const Icon(Icons.lock_outline),
                        label: const Text('Change Password'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProfileEditing
                            ? null
                            : () => vm.wellnessAction(
                                WellnessAction.logout, context),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor:
                enabled ? const Color(0xFFF5F6FA) : const Color(0xFFF0F1F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _genderDropdown({
    required bool enabled,
    required String value,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFFF5F6FA) : const Color(0xFFF0F1F5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }
}
