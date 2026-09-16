import 'package:flutter/material.dart';

import 'zaino_card_radius.dart';

class ZainoCategoryHeader extends StatelessWidget {
  const ZainoCategoryHeader({
    super.key,
    required this.category,
    this.collapsed = false,
    this.onToggleCollapsed,
    this.canMoveUp = false,
    this.canMoveDown = false,
    this.onMoveUp,
    this.onMoveDown,
  });

  /// Raw category name; empty means the "Altro" (uncategorized) group, which
  /// can be collapsed like any other but isn't reorderable.
  final String category;
  final bool collapsed;
  final VoidCallback? onToggleCollapsed;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = category.isEmpty ? 'Altro' : category;
    final reorderable = category.isNotEmpty;
    final radius = collapsed
        ? const BorderRadius.all(cardRadius)
        : const BorderRadius.vertical(top: cardRadius);

    return Container(
      margin: EdgeInsets.fromLTRB(12, 8, 12, collapsed ? 8 : 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: radius,
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: radius,
              onTap: onToggleCollapsed,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          if (reorderable) ...[
            _CaretButton(
              icon: Icons.keyboard_arrow_up,
              onPressed: canMoveUp ? onMoveUp : null,
              tooltip: 'Sposta su',
            ),
            _CaretButton(
              icon: Icons.keyboard_arrow_down,
              onPressed: canMoveDown ? onMoveDown : null,
              tooltip: 'Sposta giù',
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class _CaretButton extends StatelessWidget {
  const _CaretButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      color: theme.colorScheme.onSurfaceVariant,
      disabledColor: theme.colorScheme.onSurfaceVariant.withValues(
        alpha: 0.3,
      ),
    );
  }
}
