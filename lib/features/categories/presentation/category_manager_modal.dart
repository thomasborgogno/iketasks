import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iketasks/features/categories/domain/task_category.dart';
import 'package:iketasks/features/categories/presentation/category_cubit.dart';
import 'package:iketasks/l10n/app_localizations.dart';

class CategoryManagerModal extends StatefulWidget {
  const CategoryManagerModal({super.key});

  @override
  State<CategoryManagerModal> createState() => _CategoryManagerModalState();
}

class _CategoryManagerModalState extends State<CategoryManagerModal> {
  // Controllers for the "add new" form
  late final TextEditingController _newNameCtrl;
  late final TextEditingController _newEmojiCtrl;

  // Inline edit state — non-null when editing an existing category
  TaskCategory? _editingCategory;
  TextEditingController? _editNameCtrl;
  TextEditingController? _editEmojiCtrl;

  @override
  void initState() {
    super.initState();
    _newNameCtrl = TextEditingController();
    _newEmojiCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _newNameCtrl.dispose();
    _newEmojiCtrl.dispose();
    _editNameCtrl?.dispose();
    _editEmojiCtrl?.dispose();
    super.dispose();
  }

  void _startEdit(TaskCategory category) {
    _editNameCtrl?.dispose();
    _editEmojiCtrl?.dispose();
    setState(() {
      _editingCategory = category;
      _editNameCtrl = TextEditingController(text: category.name);
      _editEmojiCtrl = TextEditingController(text: category.emoji ?? '');
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingCategory = null;
      _editNameCtrl?.dispose();
      _editNameCtrl = null;
      _editEmojiCtrl?.dispose();
      _editEmojiCtrl = null;
    });
  }

  Future<void> _addCategory() async {
    final name = _newNameCtrl.text.trim();
    if (name.isEmpty) return;
    final emoji = _newEmojiCtrl.text.trim();
    await context.read<CategoryCubit>().createCategory(
      name,
      emoji: emoji.isEmpty ? null : emoji,
    );
    if (!mounted) return;
    _newNameCtrl.clear();
    _newEmojiCtrl.clear();
  }

  Future<void> _saveEdit() async {
    final name = _editNameCtrl!.text.trim();
    if (name.isEmpty) return;
    final emoji = _editEmojiCtrl!.text.trim();
    await context.read<CategoryCubit>().updateCategory(
      _editingCategory!.id,
      name: name,
      emoji: emoji.isEmpty ? null : emoji,
    );
    if (!mounted) return;
    _cancelEdit();
  }

  Future<void> _deleteEditing() async {
    final l10n = AppLocalizations.of(context)!;
    final category = _editingCategory!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(
          '${l10n.deleteCategoryConfirm(category.name)}\n${l10n.deleteCategoryWarning}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(d).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(d).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;
    await context.read<CategoryCubit>().deleteCategory(category.id);
    if (!mounted) return;
    _cancelEdit();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 36,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, animation) {
          final isEditView = child.key == const ValueKey('edit');
          final slideIn =
              Tween<Offset>(
                begin: Offset(isEditView ? 1.0 : -1.0, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );
          return SlideTransition(
            position: slideIn,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: _editingCategory != null
            ? KeyedSubtree(
                key: const ValueKey('edit'),
                child: _buildEditView(context),
              )
            : KeyedSubtree(
                key: const ValueKey('list'),
                child: _buildListView(context),
              ),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.categoryManagement,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.dragToReorder,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: BlocBuilder<CategoryCubit, CategoryState>(
            builder: (context, state) {
              if (state.categories.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.onboardingNoCategoriesYet,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return ReorderableListView.builder(
                shrinkWrap: true,
                onReorderItem: (oldIndex, newIndex) {
                  final updated = List<TaskCategory>.from(state.categories);
                  final item = updated.removeAt(oldIndex);
                  updated.insert(newIndex, item);
                  context.read<CategoryCubit>().reorderCategories(updated);
                },
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return ListTile(
                    key: ValueKey(category.id),
                    dense: true,
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: Icon(
                            Icons.drag_handle,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (category.emoji != null &&
                            category.emoji!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            category.emoji!,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ],
                    ),
                    title: Text(category.name),
                    onTap: () => _startEdit(category),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 64,
              child: TextField(
                controller: _newEmojiCtrl,
                decoration: InputDecoration(
                  labelText: l10n.emoji,
                  border: const OutlineInputBorder(),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _newNameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.categoryName,
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _addCategory(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        FilledButton(onPressed: _addCategory, child: Text(l10n.add)),
      ],
    );
  }

  Widget _buildEditView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _cancelEdit,
              icon: const Icon(Icons.arrow_back),
              tooltip: l10n.cancel,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.editCategory,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 64,
              child: TextField(
                controller: _editEmojiCtrl,
                decoration: InputDecoration(
                  labelText: l10n.emoji,
                  border: const OutlineInputBorder(),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _editNameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.categoryName,
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _saveEdit(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        FilledButton(onPressed: _saveEdit, child: Text(l10n.save)),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _deleteEditing,
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error),
          ),
          child: Text(l10n.deleteCategory),
        ),
      ],
    );
  }
}
