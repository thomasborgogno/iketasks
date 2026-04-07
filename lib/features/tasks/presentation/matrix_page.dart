import 'package:eisenhower_matrix_app/features/tasks/presentation/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../auth/presentation/auth_cubit.dart';
import '../../categories/domain/task_category.dart';
import '../../categories/presentation/category_cubit.dart';
import '../domain/task_item.dart';
import 'completed_page.dart';
import 'task_cubit.dart';
import 'task_completion_circle.dart';

import '../../google_tasks/data/google_tasks_repository.dart';
import '../../google_tasks/presentation/google_tasks_select_page.dart';

part 'matrix_grid_widgets.dart';
part 'task_form_sheet.dart';

enum _LayoutMode { grid, stacked }

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
  _LayoutMode _layoutMode = _LayoutMode.grid;

  static const _widgetChannel = MethodChannel('com.eisenhower.matrix/widget');

  @override
  void initState() {
    super.initState();
    _widgetChannel.setMethodCallHandler((call) async {
      if (call.method == 'openAddTask' && mounted) {
        await _openTaskForm(context);
      }
    });
  }

  void _setSelectedCategory(String? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
  }

  void _toggleLayoutMode() {
    setState(() {
      _layoutMode = _layoutMode == _LayoutMode.grid
          ? _LayoutMode.stacked
          : _LayoutMode.grid;
    });
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
                ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: const Text('Attività completate'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CompletedPage(uid: user.uid),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_download_outlined),
                  title: const Text('Importa da Google Tasks'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (pageContext) => RepositoryProvider.value(
                          value: pageContext.read<GoogleTasksRepository>(),
                          child: const GoogleTasksImportPage(),
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),
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
            onPressed: _toggleLayoutMode,
            icon: Icon(
              _layoutMode == _LayoutMode.grid
                  ? Icons.view_agenda_outlined
                  : Icons.grid_view_outlined,
            ),
            tooltip: _layoutMode == _LayoutMode.grid
                ? 'Vista a colonne'
                : 'Vista a griglia',
          ),
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
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final category in categories)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: _selectedCategoryId == category.id,
                          onSelected: (isSelected) => _setSelectedCategory(
                            isSelected ? category.id : null,
                          ),
                          label: Text(
                            category.emoji != null && category.emoji!.isNotEmpty
                                ? '${category.emoji} ${category.name}'
                                : category.name,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, categoryState) {
                final categoryEmojiMap = _selectedCategoryId == null
                    ? {
                        for (final c in categoryState.categories)
                          c.id: c.emoji ?? '',
                      }
                    : null;
                return BlocBuilder<TaskCubit, TaskState>(
                  builder: (context, state) {
                    if (state.status == TaskStatus.loading ||
                        state.status == TaskStatus.initial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == TaskStatus.error) {
                      return Center(
                        child: Text(state.errorMessage ?? 'Errore'),
                      );
                    }

                    final filtered = _selectedCategoryId == null
                        ? state.tasks
                        : state.tasks
                              .where((t) => t.categoryId == _selectedCategoryId)
                              .toList();

                    final grid = _layoutMode == _LayoutMode.grid
                        ? _MatrixGrid(
                            tasks: filtered,
                            categoryEmojiMap: categoryEmojiMap,
                            onToggleTask: (task) =>
                                context.read<TaskCubit>().toggleTask(task),
                            onTaskTap: (task) =>
                                _openTaskForm(context, existing: task),
                            onTaskMove: (task, targetQuadrant) => context
                                .read<TaskCubit>()
                                .moveTask(task, targetQuadrant),
                          )
                        : _StackedMatrix(
                            tasks: filtered,
                            categoryEmojiMap: categoryEmojiMap,
                            onToggleTask: (task) =>
                                context.read<TaskCubit>().toggleTask(task),
                            onTaskTap: (task) =>
                                _openTaskForm(context, existing: task),
                            onTaskMove: (task, targetQuadrant) => context
                                .read<TaskCubit>()
                                .moveTask(task, targetQuadrant),
                          );
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: grid,
                    );
                  },
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
        clearDescription: result.clearDescription,
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
  late final TextEditingController _emojiController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _emojiController = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    final emoji = _emojiController.text.trim();
    await context.read<CategoryCubit>().createCategory(
      name,
      emoji: emoji.isEmpty ? null : emoji,
    );
    if (!mounted) return;
    _controller.clear();
    _emojiController.clear();
  }

  Future<void> _confirmDelete(TaskCategory category) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Elimina categoria'),
        content: Text(
          'Eliminare "${category.name}"?\n'
          'Le attività associate perderanno la categoria.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(d).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(d).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;
    await context.read<CategoryCubit>().deleteCategory(category.id);
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 64,
                  child: TextField(
                    controller: _emojiController,
                    decoration: const InputDecoration(labelText: 'Emoji'),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Nome categoria',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _addCategory(),
                  ),
                ),
              ],
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
                        leading:
                            category.emoji != null && category.emoji!.isNotEmpty
                            ? Text(
                                category.emoji!,
                                style: const TextStyle(fontSize: 20),
                              )
                            : null,
                        title: Text(category.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDelete(category),
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
