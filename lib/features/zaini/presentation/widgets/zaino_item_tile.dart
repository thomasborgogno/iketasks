import 'package:flutter/material.dart';

import '../../domain/zaino_item.dart';
import 'zaino_card_radius.dart';

class ZainoItemTile extends StatelessWidget {
  const ZainoItemTile({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onToggle,
    required this.onSelectToggle,
    required this.onLongPress,
    this.isFirstInGroup = false,
    this.isLastInGroup = false,
    this.selectionMode = false,
    this.selected = false,
  });

  final ZainoItem item;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onSelectToggle;
  final VoidCallback onLongPress;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool selectionMode;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.vertical(
      top: isFirstInGroup ? cardRadius : Radius.zero,
      bottom: isLastInGroup ? cardRadius : Radius.zero,
    );
    final isSelected = selectionMode && selected;

    return Container(
      margin: EdgeInsets.fromLTRB(12, 0, 12, isLastInGroup ? 8 : 0),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Dismissible(
          key: Key('dismissible_${item.id}'),
          // Swiping either way just toggles completion — trivially
          // reversible, so no confirmation/undo banner is needed. We always
          // return false from confirmDismiss so the tile springs back to
          // place instead of being removed from the tree.
          direction: selectionMode
              ? DismissDirection.none
              : DismissDirection.horizontal,
          dismissThresholds: const {
            DismissDirection.startToEnd: 0.4,
            DismissDirection.endToStart: 0.4,
          },
          background: _SwipeToggleBackground(
            alignment: Alignment.centerLeft,
            completed: item.completed,
          ),
          secondaryBackground: _SwipeToggleBackground(
            alignment: Alignment.centerRight,
            completed: item.completed,
          ),
          confirmDismiss: (_) async {
            onToggle();
            return false;
          },
          // The outer Container above paints the selection background, so
          // ListTile needs its own nearest Material ancestor here — otherwise
          // its own background/ink splashes paint onto an ancestor Material
          // further up the tree and get hidden behind that Container.
          child: Material(
            type: MaterialType.transparency,
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: radius),
              leading: Checkbox(
                value: item.completed,
                onChanged: (_) => selectionMode ? onSelectToggle() : onToggle(),
              ),
              title: Text(
                item.title,
                style: item.completed
                    ? TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: theme.colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              trailing: item.tags.isNotEmpty
                  ? Text(
                      item.tags.join(' · '),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              // Background color for selection comes from the outer
              // Container above (so it respects the group's rounded
              // corners); the tile itself stays transparent.
              selected: isSelected,
              onTap: selectionMode ? onSelectToggle : onEdit,
              onLongPress: onLongPress,
            ),
          ),
        ),
      ),
    );
  }
}

/// Background revealed behind a [ZainoItemTile] while swiping it in either
/// direction — swiping always toggles completion, so the icon reflects
/// whichever action the swipe would perform.
class _SwipeToggleBackground extends StatelessWidget {
  const _SwipeToggleBackground({
    required this.alignment,
    required this.completed,
  });

  final Alignment alignment;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.primaryContainer,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(
        completed ? Icons.replay : Icons.check,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }
}
