import 'package:flutter/material.dart';

import '../../domain/zaino_item.dart';
import 'zaino_item_tile.dart';

/// Collapsed-by-default section listing completed items, kept separate from
/// the main (incomplete) list so finishing an item doesn't just reorder it
/// within its category but visibly moves it out of the way.
class ZainoCompletedItemsCard extends StatelessWidget {
  const ZainoCompletedItemsCard({
    super.key,
    required this.items,
    required this.selectedIds,
    required this.selectionMode,
    required this.onItemEdit,
    required this.onItemToggle,
    required this.onItemSelectToggle,
    required this.onItemLongPress,
  });

  final List<ZainoItem> items;
  final Set<String> selectedIds;
  final bool selectionMode;
  final void Function(ZainoItem) onItemEdit;
  final void Function(ZainoItem) onItemToggle;
  final void Function(String) onItemSelectToggle;
  final void Function(String) onItemLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      // Suppress the divider ExpansionTile draws above/below itself.
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        title: Text(
          'Completati (${items.length})',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          for (var i = 0; i < items.length; i++)
            ZainoItemTile(
              key: Key(items[i].id),
              item: items[i],
              isFirstInGroup: i == 0,
              isLastInGroup: i == items.length - 1,
              selectionMode: selectionMode,
              selected: selectedIds.contains(items[i].id),
              onEdit: () => onItemEdit(items[i]),
              onToggle: () => onItemToggle(items[i]),
              onSelectToggle: () => onItemSelectToggle(items[i].id),
              onLongPress: () => onItemLongPress(items[i].id),
            ),
        ],
      ),
    );
  }
}
