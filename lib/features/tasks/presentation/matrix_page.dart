import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../auth/presentation/auth_cubit.dart';
import '../../categories/domain/task_category.dart';
import '../../categories/presentation/category_cubit.dart';
import '../domain/task_item.dart';
import 'task_cubit.dart';

part 'matrix_grid_widgets.dart';
part 'task_form_sheet.dart';

const List<List<EisenhowerQuadrant>> _matrixQuadrantRows = [
  [EisenhowerQuadrant.importantUrgent, EisenhowerQuadrant.importantNotUrgent],
  [
    EisenhowerQuadrant.notImportantUrgent,
    EisenhowerQuadrant.notImportantNotUrgent,
  ],
];

class MatrixPage extends StatefulWidget {
  const MatrixPage({super.key});

  @override
  State<MatrixPage> createState() => _MatrixPageState();
}

class _MatrixPageState extends State<MatrixPage> {
  String? _selectedCategoryId;
  final Set<String> _selectedTaskIds = <String>{};

  bool get _isSelectionMode => _selectedTaskIds.isNotEmpty;

  void _setSelectedCategory(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedTaskIds.clear();
    });
  }

  void _toggleTaskSelection(String taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
      } else {
        _selectedTaskIds.add(taskId);
      }
    });
  }

  void _clearSelection() {
    if (_selectedTaskIds.isEmpty) return;
    setState(_selectedTaskIds.clear);
  }

  Future<void> _deleteSelectedTasks(BuildContext context) async {
    final selectedIds = _selectedTaskIds.toList(growable: false);
    if (selectedIds.isEmpty) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Elimina task'),
          content: Text(
            selectedIds.length == 1
                ? 'Vuoi eliminare la task selezionata?'
                : 'Vuoi eliminare ${selectedIds.length} task selezionate?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) return;

    await context.read<TaskCubit>().deleteTasks(selectedIds);
    if (!context.mounted) return;
    setState(_selectedTaskIds.clear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSelectionMode
              ? '${_selectedTaskIds.length} selezionat${_selectedTaskIds.length == 1 ? 'a' : 'e'}'
              : 'Matrice di Eisenhower',
        ),
        actions: [
          if (_isSelectionMode)
            IconButton(
              onPressed: () => _deleteSelectedTasks(context),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Elimina selezionate',
            )
          else
            IconButton(
              onPressed: () => _openCategoryManager(context),
              icon: const Icon(Icons.category_outlined),
              tooltip: 'Categorie',
            ),
          if (_isSelectionMode)
            IconButton(
              onPressed: _clearSelection,
              icon: const Icon(Icons.close),
              tooltip: 'Esci dalla selezione',
            ),
          IconButton(
            onPressed: () => context.read<AuthCubit>().signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuova task'),
      ),
      body: Column(
        children: [
          BlocBuilder<CategoryCubit, CategoryState>(
            builder: (context, state) {
              final categories = state.categories;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      selected: _selectedCategoryId == null,
                      onSelected: (_) => _setSelectedCategory(null),
                      label: const Text('Tutte'),
                    ),
                    const SizedBox(width: 8),
                    for (final category in categories)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: _selectedCategoryId == category.id,
                          onSelected: (_) => _setSelectedCategory(category.id),
                          label: Text(category.name),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<TaskCubit, TaskState>(
              builder: (context, state) {
                if (state.status == TaskStatus.loading ||
                    state.status == TaskStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == TaskStatus.error) {
                  return Center(child: Text(state.errorMessage ?? 'Errore'));
                }

                final filtered = _selectedCategoryId == null
                    ? state.tasks
                    : state.tasks
                          .where((t) => t.categoryId == _selectedCategoryId)
                          .toList();

                return Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: _MatrixGrid(
                    tasks: filtered,
                    selectedTaskIds: _selectedTaskIds,
                    isSelectionMode: _isSelectionMode,
                    onToggleTask: (task) =>
                        context.read<TaskCubit>().toggleTask(task),
                    onTaskTap: (task) {
                      if (_isSelectionMode) {
                        _toggleTaskSelection(task.id);
                        return;
                      }
                      _openTaskForm(context, existing: task);
                    },
                    onTaskLongPress: (task) => _toggleTaskSelection(task.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isSelectionMode
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FilledButton.icon(
                onPressed: () => _deleteSelectedTasks(context),
                icon: const Icon(Icons.delete_outline),
                label: Text(
                  _selectedTaskIds.length == 1
                      ? 'Elimina task selezionata'
                      : 'Elimina ${_selectedTaskIds.length} task selezionate',
                ),
              ),
            )
          : null,
    );
  }

  Future<void> _openTaskForm(BuildContext context, {TaskItem? existing}) async {
    final categories = context.read<CategoryCubit>().state.categories;
    final result = await showModalBottomSheet<_TaskFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _TaskForm(categories: categories, existing: existing),
    );
    if (!context.mounted) return;

    if (result == null) return;

    if (existing == null) {
      await context.read<TaskCubit>().createTask(
        title: result.title,
        quadrant: result.quadrant,
        description: result.description,
        dueDate: result.dueDate,
        categoryId: result.categoryId,
      );
      return;
    }

    await context.read<TaskCubit>().updateTask(
      existing.copyWith(
        title: result.title,
        description: result.description,
        dueDate: result.dueDate,
        categoryId: result.categoryId,
        quadrant: result.quadrant,
        clearDueDate: result.clearDueDate,
        clearCategory: result.clearCategory,
      ),
    );
  }

  Future<void> _openCategoryManager(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _CategoryManagerDialog(),
    );
  }
}

class _CategoryManagerDialog extends StatefulWidget {
  const _CategoryManagerDialog();

  @override
  State<_CategoryManagerDialog> createState() => _CategoryManagerDialogState();
}

class _CategoryManagerDialogState extends State<_CategoryManagerDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    await context.read<CategoryCubit>().createCategory(name);
    if (!mounted) return;
    _controller.clear();
  }

  void _closeDialog() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gestione categorie'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Nuova categoria'),
              onSubmitted: (_) => _addCategory(),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _addCategory,
              child: const Text('Aggiungi'),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, state) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      return ListTile(
                        dense: true,
                        title: Text(category.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => context
                              .read<CategoryCubit>()
                              .deleteCategory(category.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _closeDialog, child: const Text('Chiudi')),
      ],
    );
  }
}

Color _quadrantColor(EisenhowerQuadrant quadrant) {
  switch (quadrant) {
    case EisenhowerQuadrant.importantUrgent:
      return const Color(0xFFD7263D);
    case EisenhowerQuadrant.importantNotUrgent:
      return const Color(0xFF1B998B);
    case EisenhowerQuadrant.notImportantUrgent:
      return const Color(0xFFF4A261);
    case EisenhowerQuadrant.notImportantNotUrgent:
      return const Color(0xFF457B9D);
  }
}
