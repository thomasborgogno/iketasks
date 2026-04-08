import 'dart:async';

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

import '../../../core/notifications/notification_service.dart';
import '../../google_tasks/data/google_tasks_repository.dart';
import '../../google_tasks/presentation/google_tasks_select_page.dart';
import '../../widget/widget_appearance_service.dart';
import '../../widget/widget_appearance_settings.dart';

part 'matrix_grid_widgets.dart';
part 'task_form_sheet.dart';
part 'settings_widgets.dart';
part '../../widget/widget_appearance_sheet.dart';

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
  StreamSubscription<void>? _newTaskSubscription;
  bool _isModalOpen = false;

  static const _widgetChannel = MethodChannel('com.eisenhower.matrix/widget');

  @override
  void initState() {
    super.initState();
    _widgetChannel.setMethodCallHandler((call) async {
      if (_isModalOpen) return;
      if (call.method == 'openAddTask' && mounted) {
        await _openTaskForm(context);
      } else if (call.method == 'openWidgetSettings' && mounted) {
        await _openWidgetAppearance(context);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _newTaskSubscription = context
          .read<NotificationService>()
          .onNewTaskRequested
          .listen((_) {
            if (mounted) _openTaskForm(context);
          });
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

    final notificationService = context.read<NotificationService>();

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Impostazioni',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    _ProfileHeader(
                      user: user,
                      onLogout: () async {
                        Navigator.of(sheetContext).pop();
                        await context.read<AuthCubit>().signOut();
                      },
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
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
                    ListTile(
                      leading: const Icon(Icons.widgets_outlined),
                      title: const Text('Aspetto del widget'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _openWidgetAppearance(context);
                      },
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined),
                      title: const Text('Notifica persistente'),
                      subtitle: const Text(
                        'Mostra le attività prioritarie nella barra delle notifiche',
                      ),
                      value: notificationService.isEnabled,
                      onChanged: (value) async {
                        final tasks = context.read<TaskCubit>().state.tasks;
                        await notificationService.setEnabled(value, tasks);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            );
          },
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
    if (_isModalOpen) return;
    _isModalOpen = true;
    final categories = context.read<CategoryCubit>().state.categories;
    final result = await showModalBottomSheet<_TaskFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _TaskForm(categories: categories, existing: existing),
    );
    _isModalOpen = false;
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

  Future<void> _openWidgetAppearance(BuildContext context) async {
    if (_isModalOpen) return;
    _isModalOpen = true;
    final service = context.read<WidgetAppearanceService>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _WidgetAppearanceSheet(service: service),
    );
    _isModalOpen = false;
  }

  @override
  void dispose() {
    _newTaskSubscription?.cancel();
    super.dispose();
  }
}
