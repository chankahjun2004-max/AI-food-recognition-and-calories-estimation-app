import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../viewmodels/vm_navigation.dart';
import 'view_home.dart';
import 'view_insight.dart';
import 'view_history.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NavigationViewModel>();

    /// 3 tabs now (Profile/Wellness is accessed from Home via the top-right icon)
    final pages = const [
      HomeView(),
      InsightView(),
      HistoryView(),
    ];

    final safeIndex = vm.currentIndex.clamp(0, pages.length - 1);

    return Scaffold(
      body: pages[safeIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: vm.changeTab,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: 'home_tab_label'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: 'insight_tab_label'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: 'history_tab_label'.tr(),
          ),
        ],
      ),
    );
  }
}
