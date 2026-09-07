import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';

import 'features/tasks/presentation/matrix_page.dart';
import 'features/zaini/presentation/zaini_list_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  static const _pages = [
    MatrixPage(),
    ZainiListPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    // A compact, content-hugging pill rather than a nearly-full-width bar,
    // consistent with Material 3's floating navigation bar proportions.
    final barWidth = math.min(screenWidth - 64, 360.0);

    return BottomBar(
      borderRadius: BorderRadius.circular(32),
      barColor: colorScheme.surfaceContainer,
      showIcon: false,
      hideOnScroll: false,
      offset: 16,
      width: barWidth,
      fit: StackFit.expand,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.grid_view_outlined,
                selectedIcon: Icons.grid_view,
                label: 'Matrice',
                selected: _selectedIndex == 0,
                colorScheme: colorScheme,
                onTap: () => _goToPage(0),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.backpack_outlined,
                selectedIcon: Icons.backpack,
                label: 'Zaini',
                selected: _selectedIndex == 1,
                colorScheme: colorScheme,
                onTap: () => _goToPage(1),
              ),
            ),
          ],
        ),
      ),
      body: (context, controller) => PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _selectedIndex = i),
        children: _pages,
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.colorScheme,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? colorScheme.onSecondaryContainer : colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: selected
              ? BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? selectedIcon : icon, color: color, size: 24),
              if (selected) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
