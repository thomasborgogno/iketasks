import 'package:flutter/material.dart';

import '../../domain/zaino_item.dart';
import 'zaino_category_header.dart';
import 'zaino_item_row.dart';
import 'zaino_item_tile.dart';

/// Renders the incomplete items (grouped by category) as an animated sliver
/// list, reconciling additions/removals — e.g. an item completing and
/// leaving this list for the separate completed card — with a
/// fade+shrink transition instead of a jump cut.
class ZainoAnimatedItemsSliver extends StatefulWidget {
  const ZainoAnimatedItemsSliver({
    super.key,
    required this.orderedKeys,
    required this.byCategory,
    required this.selectedIds,
    required this.selectionMode,
    required this.onItemEdit,
    required this.onItemToggle,
    required this.onItemSelectToggle,
    required this.onItemLongPress,
  });

  final List<String> orderedKeys;
  final Map<String, List<ZainoItem>> byCategory;
  final Set<String> selectedIds;
  final bool selectionMode;
  final void Function(ZainoItem) onItemEdit;
  final void Function(ZainoItem) onItemToggle;
  final void Function(String) onItemSelectToggle;
  final void Function(String) onItemLongPress;

  @override
  State<ZainoAnimatedItemsSliver> createState() =>
      _ZainoAnimatedItemsSliverState();
}

class _ZainoAnimatedItemsSliverState extends State<ZainoAnimatedItemsSliver> {
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey();
  // Mirrors what SliverAnimatedList currently shows.
  late List<ZainoRow> _live;

  @override
  void initState() {
    super.initState();
    _live = buildZainoRowList(widget.orderedKeys, widget.byCategory);
  }

  @override
  void didUpdateWidget(ZainoAnimatedItemsSliver old) {
    super.didUpdateWidget(old);
    final newRows = buildZainoRowList(widget.orderedKeys, widget.byCategory);

    // SliverAnimatedList tracks its own internal item count, which only ever
    // changes via insertItem/removeItem. If the row count changes (item or
    // category added/removed — completing an item now removes its row
    // entirely, since completed items live in the separate completed card)
    // we MUST go through _reconcile to keep that count in sync — swapping
    // `_live` directly here would desync it and silently break rendering
    // until the widget is fully remounted.
    if (_live.length != newRows.length) {
      _reconcile(newRows);
      return;
    }

    // Same rows, same order — only content changed (e.g. title/tags edited,
    // or selection-mode/selected-ids re-render).
    setState(() => _live = newRows);
  }

  String _rowKey(ZainoRow r) => r is ZainoItemRow
      ? 'item:${r.item.id}'
      : 'header:${(r as ZainoHeaderRow).category}';

  Widget _rowWidget(ZainoRow row) {
    if (row is ZainoHeaderRow) {
      return ZainoCategoryHeader(category: row.category);
    }
    return _buildTile(row as ZainoItemRow);
  }

  /// Brings `_live` in line with [newRows] when the row count changed,
  /// driving SliverAnimatedList's remove/insert APIs so its internal item
  /// count never drifts out of sync with `_live.length`.
  void _reconcile(List<ZainoRow> newRows) {
    final newKeySet = newRows.map(_rowKey).toSet();
    final oldKeySet = _live.map(_rowKey).toSet();

    for (var i = _live.length - 1; i >= 0; i--) {
      if (newKeySet.contains(_rowKey(_live[i]))) continue;
      final removedRow = _live[i];
      _listKey.currentState?.removeItem(
        i,
        (ctx, anim) => SizeTransition(
          sizeFactor: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
          child: FadeTransition(opacity: anim, child: _rowWidget(removedRow)),
        ),
        duration: const Duration(milliseconds: 200),
      );
      _live.removeAt(i);
    }

    for (var i = 0; i < newRows.length; i++) {
      if (oldKeySet.contains(_rowKey(newRows[i]))) continue;
      final insertAt = i.clamp(0, _live.length);
      _live.insert(insertAt, newRows[i]);
      _listKey.currentState?.insertItem(
        insertAt,
        duration: const Duration(milliseconds: 200),
      );
    }

    // Snap final content (order, flags, edits) to the exact target — the
    // insert/remove calls above only need to land close enough to look right
    // mid-animation; correctness of the settled list comes from this.
    setState(() => _live = newRows);
  }

  Widget _buildTile(ZainoItemRow row) {
    final item = row.item;
    final selected = widget.selectedIds.contains(item.id);
    return ZainoItemTile(
      key: Key(item.id),
      item: item,
      isFirstInGroup: row.isFirstInGroup,
      isLastInGroup: row.isLastInGroup,
      selectionMode: widget.selectionMode,
      selected: selected,
      onEdit: () => widget.onItemEdit(item),
      onToggle: () => widget.onItemToggle(item),
      onSelectToggle: () => widget.onItemSelectToggle(item.id),
      onLongPress: () => widget.onItemLongPress(item.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      key: _listKey,
      initialItemCount: _live.length,
      itemBuilder: (ctx, index, animation) {
        final row = _live[index];
        if (row is ZainoHeaderRow) {
          return FadeTransition(
            opacity: animation,
            child: ZainoCategoryHeader(category: row.category),
          );
        }
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: _buildTile(row as ZainoItemRow),
        );
      },
    );
  }
}
