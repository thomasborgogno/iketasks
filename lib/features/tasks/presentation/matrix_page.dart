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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matrice di Eisenhower'),
        actions: [
          IconButton(
            onPressed: () => _openCategoryManager(context),
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Categorie',
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
                      onSelected: (_) =>
                          setState(() => _selectedCategoryId = null),
                      label: const Text('Tutte'),
                    ),
                    const SizedBox(width: 8),
                    for (final category in categories)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: _selectedCategoryId == category.id,
                          onSelected: (_) =>
                              setState(() => _selectedCategoryId = category.id),
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

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'Nessuna attivita ancora.\nPremi Nuova task per iniziare.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return GridView.count(
                  crossAxisCount: MediaQuery.sizeOf(context).width > 900
                      ? 2
                      : 1,
                  childAspectRatio: 1.15,
                  padding: const EdgeInsets.all(12),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: EisenhowerQuadrant.values
                      .map(
                        (q) => _QuadrantCard(
                          quadrant: q,
                          tasks: filtered
                              .where((t) => t.quadrant == q)
                              .toList(),
                          onDrop: (task) =>
                              context.read<TaskCubit>().moveTask(task, q),
                          onToggle: (task) =>
                              context.read<TaskCubit>().toggleTask(task),
                          onDelete: (task) =>
                              context.read<TaskCubit>().deleteTask(task.id),
                          onEdit: (task) =>
                              _openTaskForm(context, existing: task),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
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
    required this.onDrop,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  final EisenhowerQuadrant quadrant;
  final List<TaskItem> tasks;
  final ValueChanged<TaskItem> onDrop;
  final ValueChanged<TaskItem> onToggle;
  final ValueChanged<TaskItem> onDelete;
  final ValueChanged<TaskItem> onEdit;

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
    return DragTarget<TaskItem>(
      onWillAcceptWithDetails: (details) => details.data.quadrant != quadrant,
      onAcceptWithDetails: (details) => onDrop(details.data),
      builder: (context, candidateData, rejectedData) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withValues(alpha: 0.4),
                width: 1.2,
              ),
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
                    quadrant.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: tasks.isEmpty
                        ? const Center(child: Text('Vuoto'))
                        : ListView.separated(
                            itemCount: tasks.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return LongPressDraggable<TaskItem>(
                                data: task,
                                feedback: Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 280,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Text(task.title),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: _TaskTile(
                                    task: task,
                                    onToggle: () => onToggle(task),
                                    onEdit: () => onEdit(task),
                                    onDelete: () => onDelete(task),
                                  ),
                                ),
                                child: _TaskTile(
                                  task: task,
                                  onToggle: () => onToggle(task),
                                  onEdit: () => onEdit(task),
                                  onDelete: () => onDelete(task),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskItem task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final due = task.dueDate == null
        ? null
        : DateFormat('dd/MM/yyyy').format(task.dueDate!);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        leading: Checkbox(value: task.completed, onChanged: (_) => onToggle()),
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
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Modifica')),
            PopupMenuItem(value: 'delete', child: Text('Elimina')),
          ],
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
    _dueDate = widget.existing?.dueDate;
    _categoryId = widget.existing?.categoryId;
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
        left: 16,
        right: 16,
        top: 8,
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
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Descrizione'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<EisenhowerQuadrant>(
              initialValue: _quadrant,
              decoration: const InputDecoration(labelText: 'Quadrante *'),
              items: EisenhowerQuadrant.values
                  .map((q) => DropdownMenuItem(value: q, child: Text(q.label)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _quadrant = value);
                }
              },
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dueDate == null
                        ? 'Scadenza: non impostata'
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
            const SizedBox(height: 10),
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
