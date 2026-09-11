import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/zaino.dart';
import '../domain/zaino_item.dart';
import 'zaini_search_delegate.dart';
import 'zaino_cubit.dart';
import 'zaino_state.dart';
import 'widgets/zaino_category_sheet.dart';
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

  /// Maps an item id to its completed status *before* an in-flight toggle,
  /// for the brief window right after tapping its checkbox. Keeping the item
  /// classified under its pre-toggle section (incomplete vs. completed) for
  /// this window lets the user see the checkbox tick/strikethrough settle
  /// before the row animates away to its new section.
  final Map<String, bool> _frozenCompleted = {};

  bool get _selectionMode => _selectedIds.isNotEmpty;

  void _handleToggle(BuildContext context, ZainoItem item) {
    final cubit = context.read<ZainoDetailCubit>();
    setState(() => _frozenCompleted[item.id] = item.completed);
    cubit.toggleItem(item);
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _frozenCompleted.remove(item.id));
    });
  }

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
        final completed = _visibleCompleted(state);
        final incompleteCount = byCategory.values.fold<int>(
          0,
          (sum, list) => sum + list.length,
        );
        final visibleCount = incompleteCount + completed.length;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
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
                          icon: const Icon(Icons.category_outlined),
                          tooltip: 'Assegna categoria',
                          onPressed: () =>
                              _showBulkCategoryDialog(context, categories),
                        ),
                        IconButton(
                          icon: const Icon(Icons.label_outline),
                          tooltip: 'Assegna tag',
                          onPressed: state.tags.isEmpty
                              ? null
                              : () => _showBulkTagDialog(context, state),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Elimina selezionati',
                          onPressed: () => _handleBulkDelete(context, state),
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
                                onItemTap: (item) => _showEditItem(
                                  context,
                                  state,
                                  categories,
                                  item,
                                ),
                              ),
                            );
                            if (item != null && context.mounted) {
                              _showEditItem(context, state, categories, item);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          tooltip: 'Altre opzioni',
                          onPressed: () => _showOptionsSheet(context),
                        ),
                      ],
              ),
              if (!_selectionMode)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
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
              else ...[
                _buildItemsSliver(context, state, categories, byCategory),
                if (completed.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                    sliver: SliverToBoxAdapter(
                      child: _CompletedItemsCard(
                        items: completed,
                        selectedIds: _selectedIds,
                        selectionMode: _selectionMode,
                        onItemEdit: (item) =>
                            _showEditItem(context, state, categories, item),
                        onItemToggle: (item) => _handleToggle(context, item),
                        onItemSelectToggle: _toggleSelected,
                        onItemLongPress: (id) {
                          if (!_selectionMode) _toggleSelected(id);
                        },
                      ),
                    ),
                  ),
              ],
            ],
          ),
          floatingActionButton: _selectionMode
              ? null
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zaino-reset-fab',
                      tooltip: 'Reimposta tutto',
                      onPressed: () => _confirmReset(context),
                      child: const Icon(Icons.refresh),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton(
                      heroTag: 'zaino-add-fab',
                      onPressed: () => _showAddItem(context, state, categories),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
        );
      },
    );
  }

  /// Whether [item] should be classified as completed for display purposes:
  /// its real status, unless a toggle is still in its brief "freeze" window
  /// (see [_frozenCompleted]), in which case it keeps its pre-toggle section.
  bool _isCompletedForDisplay(ZainoItem item) =>
      _frozenCompleted[item.id] ?? item.completed;

  /// Incomplete items (for display) grouped by category, with pending
  /// deletes and in-flight toggle freezes applied.
  Map<String, List<ZainoItem>> _visibleByCategory(ZainoDetailState state) {
    final map = <String, List<ZainoItem>>{};
    for (final item in state.filteredItems) {
      if (_pendingDeleteIds.contains(item.id)) continue;
      if (_isCompletedForDisplay(item)) continue;
      map.putIfAbsent(item.categoryName ?? '', () => []).add(item);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.order.compareTo(b.order));
    }
    return map;
  }

  /// Completed items (for display), with pending deletes and in-flight
  /// toggle freezes applied — see [_visibleByCategory].
  List<ZainoItem> _visibleCompleted(ZainoDetailState state) {
    final list =
        state.filteredItems
            .where(
              (item) =>
                  !_pendingDeleteIds.contains(item.id) &&
                  _isCompletedForDisplay(item),
            )
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
    return list;
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
      onItemToggle: (item) => _handleToggle(context, item),
      onItemSelectToggle: _toggleSelected,
      onItemLongPress: (id) {
        if (!_selectionMode) _toggleSelected(id);
      },
    );
  }

  /// Deletes every currently-selected item (single or multi-selection alike),
  /// with an undo window via a "ANNULLA" SnackBar, then exits selection mode.
  void _handleBulkDelete(BuildContext context, ZainoDetailState state) {
    final ids = _selectedIds.toList();
    if (ids.isEmpty) return;
    final cubit = context.read<ZainoDetailCubit>();
    final items = state.items.where((i) => ids.contains(i.id)).toList();
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _pendingDeleteIds.addAll(ids);
      _selectedIds.clear();
    });
    messenger.hideCurrentSnackBar();
    messenger
        .showSnackBar(
          SnackBar(
            content: Text(
              items.length == 1
                  ? '"${items.first.title}" eliminato'
                  : '${items.length} elementi eliminati',
            ),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(label: 'ANNULLA', onPressed: () {}),
          ),
        )
        .closed
        .then((reason) {
          if (!mounted) return;
          if (reason != SnackBarClosedReason.action) {
            for (final item in items) {
              cubit.deleteItem(item);
            }
          }
          setState(() => _pendingDeleteIds.removeAll(ids));
        });
  }

  Future<void> _showBulkCategoryDialog(
    BuildContext context,
    List<String> categories,
  ) async {
    String? selectedCategory;
    final extraCategories = <String>{};
    final apply = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final allCategories = [...categories, ...extraCategories];
          return AlertDialog(
            title: const Text('Assegna categoria'),
            content: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final cat in allCategories)
                    ChoiceChip(
                      label: Text(cat),
                      selected: selectedCategory == cat,
                      onSelected: (v) => setDialogState(
                        () => selectedCategory = v ? cat : null,
                      ),
                    ),
                  ActionChip(
                    label: const Icon(Icons.add, size: 18),
                    onPressed: () async {
                      final name = await _promptForCategoryName(ctx);
                      if (name == null || name.isEmpty) return;
                      setDialogState(() {
                        if (!allCategories.contains(name)) {
                          extraCategories.add(name);
                        }
                        selectedCategory = name;
                      });
                    },
                  ),
                ],
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
          );
        },
      ),
    );
    if (apply == true && context.mounted) {
      await context.read<ZainoDetailCubit>().bulkSetCategory(
        _selectedIds.toList(),
        selectedCategory,
      );
    }
    if (mounted) _clearSelection();
  }

  Future<String?> _promptForCategoryName(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuova categoria'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Nome categoria'),
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Crea'),
          ),
        ],
      ),
    );
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
      await context.read<ZainoDetailCubit>().bulkAddTags(
        _selectedIds.toList(),
        selectedTags.toList(),
      );
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
    final cubit = context.read<ZainoDetailCubit>();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: ZainoItemFormSheet(tags: state.tags, categories: categories),
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
    final cubit = context.read<ZainoDetailCubit>();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: ZainoItemFormSheet(
          tags: state.tags,
          categories: categories,
          item: item,
        ),
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

  Future<void> _showOptionsSheet(BuildContext context) async {
    final cubit = context.read<ZainoDetailCubit>();
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.label_outline),
              title: const Text('Gestisci tag'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showTagSheet(context, cubit);
              },
            ),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Gestisci categorie'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showCategorySheet(context, cubit);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTagSheet(
    BuildContext context,
    ZainoDetailCubit cubit,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) =>
          BlocProvider.value(value: cubit, child: const ZainoTagSheet()),
    );
  }

  Future<void> _showCategorySheet(
    BuildContext context,
    ZainoDetailCubit cubit,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) =>
          BlocProvider.value(value: cubit, child: const ZainoCategorySheet()),
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
      rows.add(
        _ItemRow(
          items[i],
          isFirstInGroup: !showHeader && i == 0,
          isLastInGroup: i == items.length - 1,
        ),
      );
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
  State<_AnimatedItemsSliver> createState() => _AnimatedItemsSliverState();
}

class _AnimatedItemsSliverState extends State<_AnimatedItemsSliver> {
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey();
  // Mirrors what SliverAnimatedList currently shows.
  late List<_Row> _live;

  @override
  void initState() {
    super.initState();
    _live = _buildRowList(widget.orderedKeys, widget.byCategory);
  }

  @override
  void didUpdateWidget(_AnimatedItemsSliver old) {
    super.didUpdateWidget(old);
    final newRows = _buildRowList(widget.orderedKeys, widget.byCategory);

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

  String _rowKey(_Row r) => r is _ItemRow
      ? 'item:${r.item.id}'
      : 'header:${(r as _HeaderRow).category}';

  Widget _rowWidget(_Row row) {
    if (row is _HeaderRow) return _CategoryHeader(category: row.category);
    return _buildTile(row as _ItemRow);
  }

  /// Brings `_live` in line with [newRows] when the row count changed,
  /// driving SliverAnimatedList's remove/insert APIs so its internal item
  /// count never drifts out of sync with `_live.length`.
  void _reconcile(List<_Row> newRows) {
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

  Future<void> _addTag(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuovo tag'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Nome tag'),
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Crea'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !context.mounted) return;
    await context.read<ZainoDetailCubit>().createTag(name);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final tag in state.tags)
          FilterChip(
            label: Text(tag.name),
            selected: state.activeTagFilter.contains(tag.name),
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
        ActionChip(
          label: const Icon(Icons.add, size: 18),
          onPressed: () => _addTag(context),
        ),
      ],
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
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
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
      top: isFirstInGroup ? _cardRadius : Radius.zero,
      bottom: isLastInGroup ? _cardRadius : Radius.zero,
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
            // Background color for selection comes from the outer Container
            // above (so it respects the group's rounded corners); the tile
            // itself stays transparent.
            selected: isSelected,
            onTap: selectionMode ? onSelectToggle : onEdit,
            onLongPress: onLongPress,
          ),
        ),
      ),
    );
  }
}

/// Background revealed behind an [_ItemTile] while swiping it in either
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

class _CompletedItemsCard extends StatelessWidget {
  const _CompletedItemsCard({
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
            _ItemTile(
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
