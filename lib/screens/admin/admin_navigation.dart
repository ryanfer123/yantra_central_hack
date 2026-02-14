// lib/screens/admin/admin_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/admin_theme.dart';
import 'fleet_overview_screen.dart';
import 'triage_screen.dart';
import 'predictive_maintenance_screen.dart';
import 'driver_behavior_screen.dart';
import 'qol_screen.dart';

class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int _currentIndex = 0;

  static const _screens = [
    FleetOverviewScreen(),
    TriageScreen(),
    PredictiveMaintenanceScreen(),
    DriverBehaviorScreen(),
    QolScreen(),
  ];

  static const _navItems = [
    _AdminNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Overview',
    ),
    _AdminNavItem(
      icon: Icons.sort_outlined,
      activeIcon: Icons.sort_rounded,
      label: 'Triage',
    ),
    _AdminNavItem(
      icon: Icons.build_circle_outlined,
      activeIcon: Icons.build_circle_rounded,
      label: 'Maintain',
    ),
    _AdminNavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Drivers',
    ),
    _AdminNavItem(
      icon: Icons.tune_outlined,
      activeIcon: Icons.tune_rounded,
      label: 'Controls',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AdminTheme.bgCard,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Theme(
      data: AdminTheme.theme,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AdminTheme.bgCard,
            border: Border(
              top: BorderSide(color: AdminTheme.border, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_navItems.length, (index) {
                  final item = _navItems[index];
                  final isSelected = _currentIndex == index;
                  return _AdminNavButton(
                    item: item,
                    isSelected: isSelected,
                    hasBadge: index == 0 && true, // alerts badge on overview
                    onTap: () => setState(() => _currentIndex = index),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _AdminNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _AdminNavButton extends StatelessWidget {
  final _AdminNavItem item;
  final bool isSelected;
  final bool hasBadge;
  final VoidCallback onTap;

  const _AdminNavButton({
    required this.item,
    required this.isSelected,
    required this.hasBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AdminTheme.blue.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AdminTheme.blue.withOpacity(0.2))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  color: isSelected ? AdminTheme.blue : AdminTheme.textMuted,
                  size: 22,
                ),
                if (hasBadge && !isSelected)
                  Positioned(
                    top: -3, right: -3,
                    child: Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(
                        color: AdminTheme.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AdminTheme.blue : AdminTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}