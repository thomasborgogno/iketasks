import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../auth/presentation/auth_cubit.dart';
import '../../categories/domain/task_category.dart';
import '../../categories/presentation/category_cubit.dart';
import '../domain/task_item.dart';
import 'task_cubit.dart';

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

class _QuadrantCard extends StatelessWidget {
  const _QuadrantCard({
    required this.quadrant,
    required this.tasks,
    required this.selectedTaskIds,
    required this.isSelectionMode,
    required this.onToggle,
    required this.onTaskTap,
    required this.onTaskLongPress,
  });

  final EisenhowerQuadrant quadrant;
  final List<TaskItem> tasks;
  final Set<String> selectedTaskIds;
  final bool isSelectionMode;
  final ValueChanged<TaskItem> onToggle;
  final ValueChanged<TaskItem> onTaskTap;
  final ValueChanged<TaskItem> onTaskLongPress;

  Color _quadrantColor() {
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

  @override
  Widget build(BuildContext context) {
    final color = _quadrantColor();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.12),
              color.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quadrant.cardTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                quadrant.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Text(
                          'Vuoto',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.separated(
                        itemCount: tasks.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 0),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return _TaskTile(
                            task: task,
                            isSelected: selectedTaskIds.contains(task.id),
                            isSelectionMode: isSelectionMode,
                            onToggle: () => onToggle(task),
                            onTap: () => onTaskTap(task),
                            onLongPress: () => onTaskLongPress(task),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatrixGrid extends StatelessWidget {
  const _MatrixGrid({
    required this.tasks,
    required this.selectedTaskIds,
    required this.isSelectionMode,
    required this.onToggleTask,
    required this.onTaskTap,
    required this.onTaskLongPress,
  });

  final List<TaskItem> tasks;
  final Set<String> selectedTaskIds;
  final bool isSelectionMode;
  final ValueChanged<TaskItem> onToggleTask;
  final ValueChanged<TaskItem> onTaskTap;
  final ValueChanged<TaskItem> onTaskLongPress;

  List<TaskItem> _tasksFor(EisenhowerQuadrant quadrant) {
    return tasks.where((task) => task.quadrant == quadrant).toList();
  }

  @override
  Widget build(BuildContext context) {
    const cardSpacing = 8.0;
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _QuadrantCard(
                  quadrant: EisenhowerQuadrant.importantUrgent,
                  tasks: _tasksFor(EisenhowerQuadrant.importantUrgent),
                  selectedTaskIds: selectedTaskIds,
                  isSelectionMode: isSelectionMode,
                  onToggle: onToggleTask,
                  onTaskTap: onTaskTap,
                  onTaskLongPress: onTaskLongPress,
                ),
              ),
              const SizedBox(width: cardSpacing),
              Expanded(
                child: _QuadrantCard(
                  quadrant: EisenhowerQuadrant.importantNotUrgent,
                  tasks: _tasksFor(EisenhowerQuadrant.importantNotUrgent),
                  selectedTaskIds: selectedTaskIds,
                  isSelectionMode: isSelectionMode,
                  onToggle: onToggleTask,
                  onTaskTap: onTaskTap,
                  onTaskLongPress: onTaskLongPress,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: cardSpacing),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _QuadrantCard(
                  quadrant: EisenhowerQuadrant.notImportantUrgent,
                  tasks: _tasksFor(EisenhowerQuadrant.notImportantUrgent),
                  selectedTaskIds: selectedTaskIds,
                  isSelectionMode: isSelectionMode,
                  onToggle: onToggleTask,
                  onTaskTap: onTaskTap,
                  onTaskLongPress: onTaskLongPress,
                ),
              ),
              const SizedBox(width: cardSpacing),
              Expanded(
                child: _QuadrantCard(
                  quadrant: EisenhowerQuadrant.notImportantNotUrgent,
                  tasks: _tasksFor(EisenhowerQuadrant.notImportantNotUrgent),
                  selectedTaskIds: selectedTaskIds,
                  isSelectionMode: isSelectionMode,
                  onToggle: onToggleTask,
                  onTaskTap: onTaskTap,
                  onTaskLongPress: onTaskLongPress,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onToggle,
    required this.onTap,
    required this.onLongPress,
  });

  final TaskItem task;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final due = task.dueDate == null
        ? null
        : DateFormat('dd/MM/yyyy').format(task.dueDate!);
    final selectedColor = Theme.of(
      context,
    ).colorScheme.primaryContainer.withValues(alpha: 0.9);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: isSelected ? selectedColor : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          onLongPress: onLongPress,
          child: ListTile(
            dense: true,
            visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 0,
            ),
            horizontalTitleGap: 10,
            leading: _TaskCompletionCircle(
              completed: task.completed,
              onTap: onToggle,
            ),
            title: Text(
              task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                decoration: task.completed ? TextDecoration.lineThrough : null,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: due == null ? null : Text('Scadenza: $due'),
          ),
        ),
      ),
    );
  }
}

class _TaskCompletionCircle extends StatelessWidget {
  const _TaskCompletionCircle({required this.completed, required this.onTap});

  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 26,
        height: 30,
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed ? color : Colors.transparent,
              border: Border.all(color: color, width: 1.8),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: completed
                  ? const Icon(
                      Icons.check,
                      key: ValueKey('checked'),
                      size: 14,
                      color: Colors.white,
                    )
                  : const SizedBox(key: ValueKey('unchecked')),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskFormResult {
  const _TaskFormResult({
    required this.title,
    required this.quadrant,
    required this.description,
    required this.dueDate,
    required this.categoryId,
    required this.clearDueDate,
    required this.clearCategory,
  });

  final String title;
  final String? description;
  final DateTime? dueDate;
  final String? categoryId;
  final EisenhowerQuadrant quadrant;
  final bool clearDueDate;
  final bool clearCategory;
}

class _TaskForm extends StatefulWidget {
  const _TaskForm({required this.categories, this.existing});

  final List<TaskCategory> categories;
  final TaskItem? existing;

  @override
  State<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<_TaskForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late EisenhowerQuadrant _quadrant;
  late bool _isImportant;
  late bool _isUrgent;
  DateTime? _dueDate;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title);
    _descriptionController = TextEditingController(
      text: widget.existing?.description,
    );
    _quadrant = widget.existing?.quadrant ?? EisenhowerQuadrant.importantUrgent;
    _syncFlagsFromQuadrant(_quadrant);
    _dueDate = widget.existing?.dueDate;
    _categoryId = widget.existing?.categoryId;
  }

  void _syncFlagsFromQuadrant(EisenhowerQuadrant quadrant) {
    switch (quadrant) {
      case EisenhowerQuadrant.importantUrgent:
        _isImportant = true;
        _isUrgent = true;
      case EisenhowerQuadrant.importantNotUrgent:
        _isImportant = true;
        _isUrgent = false;
      case EisenhowerQuadrant.notImportantUrgent:
        _isImportant = false;
        _isUrgent = true;
      case EisenhowerQuadrant.notImportantNotUrgent:
        _isImportant = false;
        _isUrgent = false;
    }
  }

  void _syncQuadrantFromFlags() {
    if (_isImportant && _isUrgent) {
      _quadrant = EisenhowerQuadrant.importantUrgent;
      return;
    }
    if (_isImportant && !_isUrgent) {
      _quadrant = EisenhowerQuadrant.importantNotUrgent;
      return;
    }
    if (!_isImportant && _isUrgent) {
      _quadrant = EisenhowerQuadrant.notImportantUrgent;
      return;
    }
    _quadrant = EisenhowerQuadrant.notImportantNotUrgent;
  }

  Color _quadrantColorFor(EisenhowerQuadrant quadrant) {
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

  Widget _quadrantChoiceChip({
    required String label,
    required EisenhowerQuadrant quadrant,
  }) {
    final chipColor = _quadrantColorFor(quadrant);
    final selected = _quadrant == quadrant;

    return ChoiceChip(
      label: SizedBox(
        width: double.infinity,
        child: Text(label, textAlign: TextAlign.center),
      ),
      selected: selected,
      color: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return chipColor.withValues(alpha: 0.5);
        }
        return chipColor.withValues(alpha: 0.10);
      }),
      side: BorderSide(
        color: chipColor.withValues(alpha: selected ? 0.95 : 0.45),
      ),
      showCheckmark: false,
      onSelected: (isSelected) {
        if (!isSelected) return;
        setState(() {
          _quadrant = quadrant;
          _syncFlagsFromQuadrant(_quadrant);
        });
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEdit ? 'Modifica task' : 'Nuova task',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titolo *'),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrizione'),
            ),
            const SizedBox(height: 16),

            Text('Priorità', style: Theme.of(context).textTheme.labelMedium),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Importante'),
                    selected: _isImportant,
                    onSelected: (value) {
                      setState(() {
                        _isImportant = value;
                        _syncQuadrantFromFlags();
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Urgente'),
                    selected: _isUrgent,
                    onSelected: (value) {
                      setState(() {
                        _isUrgent = value;
                        _syncQuadrantFromFlags();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text('Quadrante', style: Theme.of(context).textTheme.labelMedium),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _quadrantChoiceChip(
                        label: 'Fai subito',
                        quadrant: EisenhowerQuadrant.importantUrgent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _quadrantChoiceChip(
                        label: 'Pianifica',
                        quadrant: EisenhowerQuadrant.importantNotUrgent,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _quadrantChoiceChip(
                        label: 'Delega',
                        quadrant: EisenhowerQuadrant.notImportantUrgent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _quadrantChoiceChip(
                        label: 'Elimina',
                        quadrant: EisenhowerQuadrant.notImportantNotUrgent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String?>(
              initialValue: _categoryId,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Nessuna categoria'),
                ),
                ...widget.categories.map(
                  (c) => DropdownMenuItem<String?>(
                    value: c.id,
                    child: Text(c.name),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 16),

            // Text('Scadenza', style: Theme.of(context).textTheme.labelMedium),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dueDate == null
                        ? 'Scadenza'
                        : 'Scadenza: ${DateFormat('dd/MM/yyyy').format(_dueDate!)}',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: _dueDate ?? DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _dueDate = picked);
                    }
                  },
                  child: const Text('Seleziona data'),
                ),
                if (_dueDate != null)
                  IconButton(
                    onPressed: () => setState(() => _dueDate = null),
                    icon: const Icon(Icons.clear),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            FilledButton(
              onPressed: () {
                final title = _titleController.text.trim();
                if (title.isEmpty) return;

                Navigator.pop(
                  context,
                  _TaskFormResult(
                    title: title,
                    quadrant: _quadrant,
                    description: _descriptionController.text.trim().isEmpty
                        ? null
                        : _descriptionController.text.trim(),
                    dueDate: _dueDate,
                    categoryId: _categoryId,
                    clearDueDate: _dueDate == null,
                    clearCategory: _categoryId == null,
                  ),
                );
              },
              child: Text(isEdit ? 'Salva modifiche' : 'Crea task'),
            ),
          ],
        ),
      ),
    );
  }
}
