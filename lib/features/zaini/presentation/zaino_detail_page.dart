import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/zaino.dart';
import '../domain/zaino_item.dart';
import 'zaini_search_delegate.dart';
import 'zaino_cubit.dart';
import 'zaino_state.dart';
import 'widgets/zaino_item_form_sheet.dart';
import 'widgets/zaino_tag_sheet.dart';

const _cardRadius = Radius.circular(16);

class ZainoDetailPage extends StatefulWidget {
  const ZainoDetailPage({super.key, required this.zaino});

  final Zaino zaino;

  @override
  State<ZainoDetailPage> createState() => _ZainoDetailPageState();
}

class _ZainoDetailPageState extends State<ZainoDetailPage> {
  Zaino get zaino => widget.zaino;

  /// Ids of items currently selected for a bulk action. Non-empty means
  /// selection mode is active.
  final Set<String> _selectedIds = {};

  /// Ids of items optimistically hidden after a swipe-to-delete, pending the
  /// undo window in the confirmation SnackBar.
  final Set<String> _pendingDeleteIds = {};

  bool get _selectionMode => _selectedIds.isNotEmpty;

  void _toggleSelected(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() => setState(_selectedIds.clear);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZainoDetailCubit, ZainoDetailState>(
      builder: (context, state) {
        final categories = _distinctCategories(state.items);
        final byCategory = _visibleByCategory(state);
        final visibleCount =
            byCategory.values.fold<int>(0, (sum, list) => sum + list.length);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                leading: _selectionMode
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Annulla selezione',
                        onPressed: _clearSelection,
                      )
                    : null,
                title: _selectionMode
                    ? Text('${_selectedIds.length} selezionati')
                    : Row(
                        children: [
                          if (zaino.emoji != null && zaino.emoji!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                zaino.emoji!,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          Expanded(child: Text(zaino.name)),
                        ],
                      ),
                actions: _selectionMode
                    ? [
                        IconButton(
                          icon: const Icon(Icons.label_outline),
                          tooltip: 'Assegna tag',
                          onPressed: state.tags.isEmpty
                              ? null
                              : () => _showBulkTagDialog(context, state),
                        ),
                      ]
                    : [
                        IconButton(
                          icon: const Icon(Icons.search),
                          tooltip: 'Cerca elemento',
                          onPressed: () async {
                            final item = await showSearch<ZainoItem?>(
                              context: context,
                              delegate: ZainoItemSearchDelegate(
                                items: state.items,
                                onItemTap: (item) =>
                                    _showEditItem(context, state, categories, item),
                              ),
                            );
                            if (item != null && context.mounted) {
                              _showEditItem(context, state, categories, item);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.label_outline),
                          tooltip: 'Gestisci tag',
                          onPressed: () => _showTagSheet(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Reimposta tutto',
                          onPressed: () => _confirmReset(context),
                        ),
                      ],
              ),
              if (!_selectionMode && state.tags.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: _TagFilterRow(state: state),
                  ),
                ),
              if (state.status == ZainoStatus.loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (visibleCount == 0)
                SliverFillRemaining(
                  child: _EmptyItems(
                    onAdd: () => _showAddItem(context, state, categories),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 96),
                  sliver: _buildItemsSliver(context, state, categories, byCategory),
                ),
            ],
          ),
          floatingActionButton: _selectionMode
              ? null
              : FloatingActionButton(
                  onPressed: () => _showAddItem(context, state, categories),
                  child: const Icon(Icons.add),
                ),
        );
      },
    );
  }

  /// [ZainoDetailState.itemsByCategory] with any pending-delete items removed.
  Map<String, List<ZainoItem>> _visibleByCategory(ZainoDetailState state) {
    final grouped = state.itemsByCategory;
    if (_pendingDeleteIds.isEmpty) return grouped;
    final result = <String, List<ZainoItem>>{};
    grouped.forEach((key, items) {
      final filtered =
          items.where((i) => !_pendingDeleteIds.contains(i.id)).toList();
      if (filtered.isNotEmpty) result[key] = filtered;
    });
    return result;
  }

  Widget _buildItemsSliver(
    BuildContext context,
    ZainoDetailState state,
    List<String> categories,
    Map<String, List<ZainoItem>> byCategory,
  ) {
    final orderedKeys = _orderedCategoryKeys(byCategory);
    return _AnimatedItemsSliver(
      key: const ValueKey('animated-items'),
      orderedKeys: orderedKeys,
      byCategory: byCategory,
      selectedIds: _selectedIds,
      selectionMode: _selectionMode,
      onItemEdit: (item) => _showEditItem(context, state, categories, item),
      onItemDelete: (item) => _handleDeleteRequested(context, item),
      onItemToggle: (item) => context.read<ZainoDetailCubit>().toggleItem(item),
      onItemSelectToggle: _toggleSelected,
      onItemLongPress: (id) {
        if (!_selectionMode) _toggleSelected(id);
      },
    );
  }

  void _handleDeleteRequested(BuildContext context, ZainoItem item) {
    final cubit = context.read<ZainoDetailCubit>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _pendingDeleteIds.add(item.id));
    messenger.hideCurrentSnackBar();
    messenger
        .showSnackBar(
          SnackBar(
            content: Text('"${item.title}" eliminato'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(label: 'ANNULLA', onPressed: () {}),
          ),
        )
        .closed
        .then((reason) {
      if (!mounted) return;
      if (reason != SnackBarClosedReason.action) {
        cubit.deleteItem(item);
      }
      setState(() => _pendingDeleteIds.remove(item.id));
    });
  }

  Future<void> _showBulkTagDialog(
    BuildContext context,
    ZainoDetailState state,
  ) async {
    final selectedTags = <String>{};
    final apply = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Assegna tag'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: state.tags.map((tag) {
                final selected = selectedTags.contains(tag.name);
                return FilterChip(
                  label: Text(tag.name),
                  selected: selected,
                  onSelected: (v) => setDialogState(() {
                    if (v) {
                      selectedTags.add(tag.name);
                    } else {
                      selectedTags.remove(tag.name);
                    }
                  }),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Applica'),
            ),
          ],
        ),
      ),
    );
    if (apply == true && selectedTags.isNotEmpty && context.mounted) {
      await context
          .read<ZainoDetailCubit>()
          .bulkAddTags(_selectedIds.toList(), selectedTags.toList());
    }
    if (mounted) _clearSelection();
  }

  List<String> _orderedCategoryKeys(Map<String, List<ZainoItem>> map) {
    final keys = map.keys.toList();
    final named = keys.where((k) => k.isNotEmpty).toList()..sort();
    final unnamed = keys.where((k) => k.isEmpty).toList();
    return [...named, ...unnamed];
  }

  List<String> _distinctCategories(List<ZainoItem> items) {
    final seen = <String>{};
    final result = <String>[];
    for (final item in items) {
      final cat = item.categoryName;
      if (cat != null && cat.isNotEmpty && seen.add(cat)) {
        result.add(cat);
      }
    }
    return result;
  }

  Future<void> _showAddItem(
    BuildContext context,
    ZainoDetailState state,
    List<String> categories,
  ) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ZainoItemFormSheet(
        tags: state.tags,
        categories: categories,
      ),
    );
    if (result == null || !context.mounted) return;
    await context.read<ZainoDetailCubit>().createItem(
      title: result['title'] as String,
      categoryName: result['categoryName'] as String?,
      tags: List<String>.from(result['tags'] as List),
    );
  }

  Future<void> _showEditItem(
    BuildContext context,
    ZainoDetailState state,
    List<String> categories,
    ZainoItem item,
  ) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ZainoItemFormSheet(
        tags: state.tags,
        categories: categories,
        item: item,
      ),
    );
    if (result == null || !context.mounted) return;
    final categoryName = result['categoryName'] as String?;
    await context.read<ZainoDetailCubit>().updateItem(
      item,
      title: result['title'] as String,
      categoryName: categoryName,
      tags: List<String>.from(result['tags'] as List),
      clearCategoryName: categoryName == null,
    );
  }

  Future<void> _showTagSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => BlocProvider.value(
        value: context.read<ZainoDetailCubit>(),
        child: const ZainoTagSheet(),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reimposta zaino'),
        content: const Text(
          'Tutti gli elementi verranno deselezionati. Continuare?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reimposta'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ZainoDetailCubit>().resetAll();
    }
  }
}

// ── Row model ────────────────────────────────────────────────────────────────

sealed class _Row {
  const _Row();
}

class _HeaderRow extends _Row {
  const _HeaderRow(this.category);
  final String category;
}

class _ItemRow extends _Row {
  const _ItemRow(
    this.item, {
    this.isFirstInGroup = false,
    this.isLastInGroup = false,
  });
  final ZainoItem item;
  final bool isFirstInGroup;
  final bool isLastInGroup;
}

List<_Row> _buildRowList(
  List<String> orderedKeys,
  Map<String, List<ZainoItem>> byCategory,
) {
  final hasNamedCategory = orderedKeys.any((k) => k.isNotEmpty);
  final rows = <_Row>[];
  for (final cat in orderedKeys) {
    final items = byCategory[cat] ?? const [];
    if (items.isEmpty) continue;
    final showHeader = cat.isNotEmpty || hasNamedCategory;
    if (cat.isNotEmpty) {
      rows.add(_HeaderRow(cat));
    } else if (hasNamedCategory) {
      rows.add(const _HeaderRow('Altro'));
    }
    for (var i = 0; i < items.length; i++) {
      rows.add(_ItemRow(
        items[i],
        isFirstInGroup: !showHeader && i == 0,
        isLastInGroup: i == items.length - 1,
      ));
    }
  }
  return rows;
}

// ── Animated sliver ──────────────────────────────────────────────────────────

class _AnimatedItemsSliver extends StatefulWidget {
  const _AnimatedItemsSliver({
    super.key,
    required this.orderedKeys,
    required this.byCategory,
    required this.selectedIds,
    required this.selectionMode,
    required this.onItemEdit,
    required this.onItemDelete,
    required this.onItemToggle,
    required this.onItemSelectToggle,
    required this.onItemLongPress,
  });

  final List<String> orderedKeys;
  final Map<String, List<ZainoItem>> byCategory;
  final Set<String> selectedIds;
  final bool selectionMode;
  final void Function(ZainoItem) onItemEdit;
  final void Function(ZainoItem) onItemDelete;
  final void Function(ZainoItem) onItemToggle;
  final void Function(String) onItemSelectToggle;
  final void Function(String) onItemLongPress;

  @override
  State<_AnimatedItemsSliver> createState() => _AnimatedItemsSliverState();
}

class _AnimatedItemsSliverState extends State<_AnimatedItemsSliver> {
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey();
  // Mirrors what SliverAnimatedList currently shows.
  late List<_Row> _live;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _live = _buildRowList(widget.orderedKeys, widget.byCategory);
  }

  @override
  void didUpdateWidget(_AnimatedItemsSliver old) {
    super.didUpdateWidget(old);
    final newRows = _buildRowList(widget.orderedKeys, widget.byCategory);

    // Find items whose completion status changed.
    final oldItemMap = {
      for (final r in _live)
        if (r is _ItemRow) r.item.id: r.item,
    };
    final newItemMap = {
      for (final r in newRows)
        if (r is _ItemRow) r.item.id: r.item,
    };
    final changedIds = <String>{
      for (final id in oldItemMap.keys)
        if (newItemMap.containsKey(id) &&
            newItemMap[id]!.completed != oldItemMap[id]!.completed)
          id,
    };

    // SliverAnimatedList tracks its own internal item count, which only ever
    // changes via insertItem/removeItem. If the row count changes (item or
    // category added/removed) we MUST go through _reconcile to keep that
    // count in sync — swapping `_live` directly here would desync it and
    // silently break rendering until the widget is fully remounted (which is
    // exactly why new items/categories used to only show up after leaving
    // and re-entering the page).
    if (_live.length != newRows.length || changedIds.length > 3) {
      _reconcile(newRows);
      return;
    }

    if (changedIds.isEmpty) {
      // Same rows, same order — only content changed (e.g. title/tags
      // edited, or selection-mode/selected-ids re-render).
      setState(() => _live = newRows);
      return;
    }

    // Only completion status changed for 1-3 items: nice two-phase animation.
    _animateCompletionChange(newRows, changedIds);
  }

  String _rowKey(_Row r) =>
      r is _ItemRow ? 'item:${r.item.id}' : 'header:${(r as _HeaderRow).category}';

  Widget _rowWidget(_Row row) {
    if (row is _HeaderRow) return _CategoryHeader(category: row.category);
    return _buildTile(row as _ItemRow);
  }

  /// Brings `_live` in line with [newRows] when the row count changed,
  /// driving SliverAnimatedList's remove/insert APIs so its internal item
  /// count never drifts out of sync with `_live.length`.
  void _reconcile(List<_Row> newRows) {
    // Invalidate any in-flight two-phase completion animation: its captured
    // indices would no longer be valid once the row set changes structurally.
    _generation++;
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

  /// Phase 1: update the checkbox + strikethrough for the toggled items
  /// immediately, in place, with no reordering. Phase 2: after a short pause
  /// (so the user clearly sees the checked state), animate the item(s) out of
  /// their old spot and back in at the bottom of their category.
  void _animateCompletionChange(List<_Row> newRows, Set<String> changedIds) {
    final newItemMap = {
      for (final r in newRows)
        if (r is _ItemRow) r.item.id: r.item,
    };

    setState(() {
      for (final id in changedIds) {
        final idx = _live.indexWhere((r) => r is _ItemRow && r.item.id == id);
        if (idx < 0) continue;
        final newItem = newItemMap[id];
        if (newItem == null) continue;
        final oldRow = _live[idx] as _ItemRow;
        _live[idx] = _ItemRow(
          newItem,
          isFirstInGroup: oldRow.isFirstInGroup,
          isLastInGroup: oldRow.isLastInGroup,
        );
      }
    });

    final generation = ++_generation;
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted || generation != _generation) return;

      final removals = <(int, ZainoItem)>[];
      for (final id in changedIds) {
        final idx = _live.indexWhere((r) => r is _ItemRow && r.item.id == id);
        if (idx >= 0) removals.add((idx, (_live[idx] as _ItemRow).item));
      }
      removals.sort((a, b) => b.$1.compareTo(a.$1));

      for (final (idx, item) in removals) {
        _listKey.currentState?.removeItem(
          idx,
          (ctx, anim) => SizeTransition(
            sizeFactor: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
            child: FadeTransition(
              opacity: anim,
              child: _buildTile(_ItemRow(item)),
            ),
          ),
          duration: const Duration(milliseconds: 250),
        );
        _live.removeAt(idx);
      }

      Future.delayed(const Duration(milliseconds: 270), () {
        if (!mounted || generation != _generation) return;
        for (final id in changedIds) {
          final newIdx =
              newRows.indexWhere((r) => r is _ItemRow && r.item.id == id);
          if (newIdx < 0) continue;
          final newRow = newRows[newIdx] as _ItemRow;

          int insertAt = _live.length;
          for (int i = newIdx - 1; i >= 0; i--) {
            final pred = newRows[i];
            final liveIdx = _live.indexWhere((r) {
              if (r is _ItemRow && pred is _ItemRow) return r.item.id == pred.item.id;
              if (r is _HeaderRow && pred is _HeaderRow) {
                return r.category == pred.category;
              }
              return false;
            });
            if (liveIdx >= 0) {
              insertAt = liveIdx + 1;
              break;
            }
          }
          insertAt = insertAt.clamp(0, _live.length);
          _live.insert(insertAt, newRow);
          _listKey.currentState?.insertItem(
            insertAt,
            duration: const Duration(milliseconds: 250),
          );
        }
        setState(() {});
      });
    });
  }

  Widget _buildTile(_ItemRow row) {
    final item = row.item;
    final selected = widget.selectedIds.contains(item.id);
    return _ItemTile(
      key: Key(item.id),
      item: item,
      isFirstInGroup: row.isFirstInGroup,
      isLastInGroup: row.isLastInGroup,
      selectionMode: widget.selectionMode,
      selected: selected,
      onEdit: () => widget.onItemEdit(item),
      onDelete: () => widget.onItemDelete(item),
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
        if (row is _HeaderRow) {
          return FadeTransition(
            opacity: animation,
            child: _CategoryHeader(category: row.category),
          );
        }
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: _buildTile(row as _ItemRow),
        );
      },
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _TagFilterRow extends StatelessWidget {
  const _TagFilterRow({required this.state});

  final ZainoDetailState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: state.tags.map((tag) {
          final active = state.activeTagFilter.contains(tag.name);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(tag.name),
              selected: active,
              onSelected: (v) {
                final current = List<String>.from(state.activeTagFilter);
                if (v) {
                  current.add(tag.name);
                } else {
                  current.remove(tag.name);
                }
                context.read<ZainoDetailCubit>().setTagFilter(current);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: _cardRadius),
      ),
      child: Text(
        category,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
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
  final VoidCallback onDelete;
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
      top: isFirstInGroup ? _cardRadius : Radius.zero,
      bottom: isLastInGroup ? _cardRadius : Radius.zero,
    );

    return Container(
      margin: EdgeInsets.fromLTRB(12, 0, 12, isLastInGroup ? 12 : 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Dismissible(
          key: Key('dismissible_${item.id}'),
          direction:
              selectionMode ? DismissDirection.none : DismissDirection.endToStart,
          // Require a larger swipe than the default before committing to a
          // delete, so a shallow edge-swipe (e.g. the OS "back" gesture)
          // doesn't accidentally remove an item.
          dismissThresholds: const {DismissDirection.endToStart: 0.6},
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: theme.colorScheme.errorContainer,
            child: Icon(
              Icons.delete_outline,
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          onDismissed: (_) => onDelete(),
          child: ListTile(
            leading: Checkbox(
              value: selectionMode ? selected : item.completed,
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
            subtitle: item.tags.isNotEmpty
                ? Wrap(
                    spacing: 4,
                    children: item.tags
                        .map(
                          (t) => Chip(
                            label: Text(t, style: const TextStyle(fontSize: 11)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  )
                : null,
            selected: selectionMode && selected,
            selectedTileColor:
                theme.colorScheme.secondaryContainer.withValues(alpha: 0.35),
            onTap: selectionMode ? onSelectToggle : onEdit,
            onLongPress: onLongPress,
          ),
        ),
      ),
    );
  }
}

class _EmptyItems extends StatelessWidget {
  const _EmptyItems({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.checklist_outlined,
              size: 64,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Nessun elemento',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi elemento'),
            ),
          ],
        ),
      ),
    );
  }
}
