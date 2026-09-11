import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/zaino.dart';
import '../domain/zaino_item.dart';
import 'zaini_search_delegate.dart';
import 'zaino_detail_cubit.dart';
import 'zaino_state.dart';
import 'widgets/zaino_animated_items_sliver.dart';
import 'widgets/zaino_category_sheet.dart';
import 'widgets/zaino_completed_items_card.dart';
import 'widgets/zaino_empty_items.dart';
import 'widgets/zaino_item_form_sheet.dart';
import 'widgets/zaino_tag_filter_row.dart';
import 'widgets/zaino_tag_sheet.dart';

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
                    child: ZainoTagFilterRow(state: state),
                  ),
                ),
              if (state.status == ZainoStatus.loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (visibleCount == 0)
                SliverFillRemaining(
                  child: ZainoEmptyItems(
                    onAdd: () => _showAddItem(context, state, categories),
                  ),
                )
              else ...[
                _buildItemsSliver(context, state, categories, byCategory),
                if (completed.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                    sliver: SliverToBoxAdapter(
                      child: ZainoCompletedItemsCard(
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
    return ZainoAnimatedItemsSliver(
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
