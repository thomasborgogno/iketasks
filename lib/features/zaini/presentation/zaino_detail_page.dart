import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/zaino.dart';
import '../domain/zaino_item.dart';
import 'zaini_search_delegate.dart';
import 'zaino_cubit.dart';
import 'zaino_state.dart';
import 'widgets/zaino_item_form_sheet.dart';
import 'widgets/zaino_tag_sheet.dart';

class ZainoDetailPage extends StatelessWidget {
  const ZainoDetailPage({super.key, required this.zaino});

  final Zaino zaino;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZainoDetailCubit, ZainoDetailState>(
      builder: (context, state) {
        final categories = _distinctCategories(state.items);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Row(
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
                actions: [
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
              if (state.tags.isNotEmpty)
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
              else if (state.filteredItems.isEmpty)
                SliverFillRemaining(
                  child: _EmptyItems(
                    onAdd: () => _showAddItem(context, state, categories),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 96),
                  sliver: _buildItemsSliver(context, state, categories),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddItem(context, state, categories),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildItemsSliver(
    BuildContext context,
    ZainoDetailState state,
    List<String> categories,
  ) {
    final byCategory = state.itemsByCategory;
    final orderedKeys = _orderedCategoryKeys(byCategory);
    final rows = <Widget>[];
    for (final cat in orderedKeys) {
      if (cat.isNotEmpty) {
        rows.add(_CategoryHeader(category: cat));
      }
      for (final item in byCategory[cat]!) {
        rows.add(
          _ItemTile(
            key: Key(item.id),
            item: item,
            onEdit: () => _showEditItem(context, state, categories, item),
            onDelete: () => context.read<ZainoDetailCubit>().deleteItem(item),
            onToggle: () => context.read<ZainoDetailCubit>().toggleItem(item),
          ),
        );
      }
    }
    return SliverList.list(children: rows);
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
  });

  final ZainoItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('dismissible_${item.id}'),
      direction: DismissDirection.endToStart,
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
          value: item.completed,
          onChanged: (_) => onToggle(),
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
        onTap: onEdit,
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
