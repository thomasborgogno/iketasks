import 'package:firebase_auth/firebase_auth.dart';
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

  void _setSelectedCategory(String? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
  }

  User? _getUser() {
    return context.read<AuthCubit>().state.user;
  }

  Future<void> _openSettingsOverlay(BuildContext context) async {
    final user = _getUser();
    if (user == null) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Impostazioni',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                _ProfileHeader(user: user),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      Navigator.of(sheetContext).pop();
                      await context.read<AuthCubit>().signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _getUser();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          user?.displayName?.trim().split(' ').firstOrNull == null
              ? 'La tua matrice di Eisenhower'
              : 'Ciao, ${user?.displayName?.trim().split(' ').first}!',
        ),
        actions: [
          IconButton(
            onPressed: () => _openCategoryManager(context),
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Categorie',
          ),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final user = state.user;
              return IconButton(
                onPressed: user == null
                    ? null
                    : () => _openSettingsOverlay(context),
                tooltip: 'Profilo e impostazioni',
                icon: _ProfileAvatar(photoUrl: user?.photoURL, radius: 20),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTaskForm(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          BlocBuilder<CategoryCubit, CategoryState>(
            builder: (context, state) {
              final categories = state.categories;
              if (categories.isEmpty) return const SizedBox.shrink();
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
                    onToggleTask: (task) =>
                        context.read<TaskCubit>().toggleTask(task),
                    onTaskTap: (task) => _openTaskForm(context, existing: task),
                    onTaskMove: (task, targetQuadrant) => context
                        .read<TaskCubit>()
                        .moveTask(task, targetQuadrant),
                  ),
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final name = user.displayName?.trim();
    final email = user.email?.trim();
    return Row(
      children: [
        _ProfileAvatar(photoUrl: user.photoURL, radius: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (name == null || name.isEmpty) ? 'Utente Google' : name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (email != null && email.isNotEmpty)
                Text(email, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photoUrl, this.radius = 18});

  final String? photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final validPhotoUrl = photoUrl != null && photoUrl!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      foregroundImage: validPhotoUrl ? NetworkImage(photoUrl!) : null,
      child: validPhotoUrl
          ? null
          : Icon(
              Icons.person,
              size: radius,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
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
