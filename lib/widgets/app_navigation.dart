import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import './custom_icon_widget.dart';

class _TabSpec {
  final String label;
  final String icon;
  final String activeIcon;
  final int branchIndex;

  const _TabSpec({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.branchIndex,
  });
}

class AppNavigation extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppNavigation({required this.navigationShell, super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  static const List<_TabSpec> _tabs = [
    _TabSpec(
      label: 'Home',
      icon: 'home_outlined',
      activeIcon: 'home_rounded',
      branchIndex: 0,
    ),
    _TabSpec(
      label: 'Study',
      icon: 'menu_book_outlined',
      activeIcon: 'menu_book_rounded',
      branchIndex: 1,
    ),
    _TabSpec(
      label: 'Workout',
      icon: 'fitness_center_outlined',
      activeIcon: 'fitness_center_rounded',
      branchIndex: 2,
    ),
    _TabSpec(
      label: 'Block Apps',
      icon: 'block_outlined',
      activeIcon: 'block_rounded',
      branchIndex: 3,
    ),
  ];

  void _onTabTap(int visualIndex) {
    final tab = _tabs[visualIndex];
    widget.navigationShell.goBranch(
      tab.branchIndex,
      initialLocation: tab.branchIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomPadding + 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark.withAlpha(191),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppTheme.glassBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(77),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppTheme.primary.withAlpha(20),
                  blurRadius: 32,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final isActive = currentIndex == index;

                return GestureDetector(
                  onTap: () => _onTabTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.primary.withAlpha(51)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: isActive ? tab.activeIcon : tab.icon,
                          color: isActive
                              ? AppTheme.primaryLight
                              : AppTheme.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isActive
                                ? AppTheme.primaryLight
                                : AppTheme.textSecondary,
                          ),
                          child: Text(tab.label),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
