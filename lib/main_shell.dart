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

  static const _pages = [MatrixPage(), ZainiListPage()];

  static const _navItems = [
    (
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view,
      label: 'Matrice',
    ),
    (
      icon: Icons.backpack_outlined,
      selectedIcon: Icons.backpack,
      label: 'Zaini',
    ),
  ];

  static const _labelStyle = TextStyle(
    fontFamily: 'GoogleSansFlex',
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

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

  double _itemWidth(String label, bool selected, TextScaler textScaler) {
    final labelWidth = (TextPainter(
      text: TextSpan(text: label, style: _labelStyle),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout()).width;
    final iconPart = selected ? _NavItem.iconSize + _NavItem.iconLabelGap : 0.0;
    // Small safety margin: text measurement can be a fraction of a pixel
    // narrower than what actually gets laid out/rounded on screen.
    return _NavItem.horizontalPadding * 2 + iconPart + labelWidth + 2;
  }

  static const double _barHorizontalPadding = 8;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScaler = MediaQuery.of(context).textScaler;

    final barWidth =
        [
          for (var i = 0; i < _navItems.length; i++)
            _itemWidth(_navItems[i].label, i == _selectedIndex, textScaler),
        ].fold<double>(0, (a, b) => a + b) +
        _barHorizontalPadding * 2;

    return BottomBar(
      borderRadius: BorderRadius.circular(32),
      barColor: colorScheme.surfaceContainer,
      showIcon: false,
      hideOnScroll: false,
      width: barWidth,
      fit: StackFit.expand,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _barHorizontalPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _navItems.length; i++)
                _NavItem(
                  icon: _navItems[i].icon,
                  selectedIcon: _navItems[i].selectedIcon,
                  label: _navItems[i].label,
                  selected: _selectedIndex == i,
                  colorScheme: colorScheme,
                  onTap: () => _goToPage(i),
                ),
            ],
          ),
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

  static const double horizontalPadding = 12;
  static const double verticalPadding = 8;
  static const double iconSize = 24;
  static const double iconLabelGap = 8;

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurface;

    final radius = BorderRadius.circular(20);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: selected ? colorScheme.secondaryContainer : Colors.transparent,
        borderRadius: radius,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  Icon(selectedIcon, color: color, size: iconSize),
                  const SizedBox(width: iconLabelGap),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
