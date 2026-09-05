import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iketasks/l10n/app_localizations.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/utils/fuzzy_search.dart';
import '../../auth/presentation/auth_cubit.dart';
import '../../categories/presentation/category_cubit.dart';
import '../domain/task_item.dart';
import 'matrix_enums.dart';
import 'task_search_delegate.dart';
import 'widgets/matrix_grid_widgets.dart';
import 'package:iketasks/features/categories/presentation/category_manager_modal.dart';
import '../data/matrix_prefs_service.dart';
import 'matrix_settings_sheet.dart';
import 'matrix_support_widgets.dart';
import 'task_cubit.dart';
import 'task_form_sheet.dart';

class MatrixPage extends StatefulWidget {
  const MatrixPage({super.key});

  @override
  State<MatrixPage> createState() => _MatrixPageState();
}

class _MatrixPageState extends State<MatrixPage> {
  Set<String> _selectedCategoryIds = {};
  Set<String> _excludedCategoryIds = {};
  bool _showPostponed = false;
  MatrixLayoutMode _layoutMode = MatrixLayoutMode.grid;
  TaskInputMode _taskInputMode = TaskInputMode.quadrantOnly;
  StreamSubscription<void>? _newTaskSubscription;
  bool _isModalOpen = false;
  String _searchQuery = '';

  static const _widgetChannel = MethodChannel('com.eisenhower.matrix/widget');

  @override
  void initState() {
    super.initState();
    _widgetChannel.setMethodCallHandler((call) async {
      if (_isModalOpen) return;
      if (call.method == 'openAddTask' && mounted) {
        await _openTaskForm(context);
      } else if (call.method == 'openWidgetSettings' && mounted) {
        await showWidgetAppearanceSheet(context);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _newTaskSubscription = context
          .read<NotificationService>()
          .onNewTaskRequested
          .listen((_) {
            if (mounted) _openTaskForm(context);
          });
      unawaited(_loadPrefs());
    });
  }

  Future<void> _loadPrefs() async {
    final prefs = context.read<MatrixPrefsService>();
    final inputMode = await prefs.loadTaskInputMode();
    final selectedIds = await prefs.loadSelectedCategories();
    final excludedIds = await prefs.loadExcludedCategories();
    final layoutMode = await prefs.loadLayoutMode();
    if (!mounted) return;
    setState(() {
      _taskInputMode = inputMode;
      _selectedCategoryIds = selectedIds;
      _excludedCategoryIds = excludedIds;
      _layoutMode = layoutMode;
    });
  }

  void _toggleCategorySelection(String categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds = Set<String>.from(_selectedCategoryIds)
          ..remove(categoryId);
      } else {
        _selectedCategoryIds = Set<String>.from(_selectedCategoryIds)
          ..add(categoryId);
        _excludedCategoryIds = {};
        _showPostponed = false;
      }
    });
    unawaited(context.read<MatrixPrefsService>().saveSelectedCategories(_selectedCategoryIds));
    unawaited(context.read<MatrixPrefsService>().saveExcludedCategories(_excludedCategoryIds));
  }

  void _excludeCategory(String categoryId) {
    setState(() {
      _selectedCategoryIds = {};
      if (_excludedCategoryIds.contains(categoryId)) {
        _excludedCategoryIds = Set<String>.from(_excludedCategoryIds)
          ..remove(categoryId);
      } else {
        _excludedCategoryIds = Set<String>.from(_excludedCategoryIds)
          ..add(categoryId);
      }
    });
    unawaited(context.read<MatrixPrefsService>().saveSelectedCategories(_selectedCategoryIds));
    unawaited(context.read<MatrixPrefsService>().saveExcludedCategories(_excludedCategoryIds));
  }

  void _toggleShowPostponed() {
    setState(() {
      _showPostponed = !_showPostponed;
      // Clear selected categories in memory only — not saved to prefs,
      // so they are restored when toggling postponed off or reopening the app.
      if (_showPostponed) {
        _selectedCategoryIds = {};
        _excludedCategoryIds = {};
      }
    });
  }

  void _toggleLayoutMode() {
    setState(() {
      _layoutMode = _layoutMode == MatrixLayoutMode.grid
          ? MatrixLayoutMode.stacked
          : MatrixLayoutMode.grid;
    });
    unawaited(context.read<MatrixPrefsService>().saveLayoutMode(_layoutMode));
  }

  User? _getUser() => context.read<AuthCubit>().state.user;

  Future<void> _openSettingsOverlay(BuildContext context) async {
    final user = _getUser();
    if (user == null) return;
    final prefs = context.read<MatrixPrefsService>();
    final isAnonymous = context.read<AuthCubit>().state.isAnonymous;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => MatrixSettingsSheet(
        user: user,
        isAnonymous: isAnonymous,
        taskInputMode: _taskInputMode,
        onTaskInputModeChanged: (mode) {
          setState(() => _taskInputMode = mode);
          unawaited(prefs.saveTaskInputMode(mode));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _getUser();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          user?.displayName?.trim().split(' ').firstOrNull == null
              ? l10n.yourEisenhowerMatrix
              : l10n.greeting(user!.displayName!.trim().split(' ').first),
        ),
        actions: [
          BlocBuilder<TaskCubit, TaskState>(
            builder: (context, taskState) {
              return IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Cerca task',
                onPressed: () async {
                  final result = await showSearch<TaskItem?>(
                    context: context,
                    delegate: TaskSearchDelegate(
                      tasks: taskState.tasks,
                      onTaskTap: (task) => _openTaskForm(context, existing: task),
                    ),
                    query: _searchQuery,
                  );
                  if (result == null) setState(() => _searchQuery = '');
                },
              );
            },
          ),
          IconButton(
            onPressed: _toggleLayoutMode,
            icon: Icon(
              _layoutMode == MatrixLayoutMode.grid
                  ? Icons.view_agenda_outlined
                  : Icons.grid_view_outlined,
            ),
            tooltip: _layoutMode == MatrixLayoutMode.grid
                ? l10n.columnView
                : l10n.gridView,
          ),
          IconButton(
            onPressed: () => _openCategoryManager(context),
            icon: const Icon(Icons.category_outlined),
            tooltip: l10n.categories,
          ),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final user = state.user;
              return IconButton(
                onPressed: user == null
                    ? null
                    : () => _openSettingsOverlay(context),
                tooltip: l10n.profileAndSettings,
                icon: ProfileAvatar(photoUrl: user?.photoURL, radius: 20),
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
          BlocBuilder<TaskCubit, TaskState>(
            builder: (context, taskState) {
              final hasPostponed = taskState.postponedTasks.isNotEmpty;
              return BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, state) {
                  final categories = state.categories;
                  if (categories.isEmpty && !hasPostponed)
                    return const SizedBox.shrink();
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final category in categories)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onLongPress: () =>
                                  _excludeCategory(category.id),
                              child: () {
                                final isSelected =
                                    _selectedCategoryIds.contains(category.id);
                                final isExcluded =
                                    _excludedCategoryIds.contains(category.id);
                                final labelText = category.emoji != null &&
                                        category.emoji!.isNotEmpty
                                    ? '${category.emoji} ${category.name}'
                                    : category.name;
                                final errorColor =
                                    Theme.of(context).colorScheme.error;
                                return FilterChip(
                                  selected: isSelected,
                                  onSelected: (_) =>
                                      _toggleCategorySelection(category.id),
                                  backgroundColor: isExcluded
                                      ? errorColor.withValues(alpha: 0.15)
                                      : null,
                                  labelStyle: isExcluded
                                      ? TextStyle(color: errorColor)
                                      : null,
                                  avatar: isExcluded
                                      ? Icon(
                                          Icons.close,
                                          size: 14,
                                          color: errorColor,
                                        )
                                      : null,
                                  label: Text(labelText),
                                );
                              }(),
                            ),
                          ),
                        if (hasPostponed)
                          FilterChip(
                            selected: _showPostponed,
                            onSelected: (_) => _toggleShowPostponed(),
                            label: const Icon(
                              Icons.schedule_outlined,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          Expanded(
            child: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, categoryState) {
                final categoryEmojiMap = {
                  for (final c in categoryState.categories)
                    c.id: c.emoji ?? '',
                };
                return BlocBuilder<TaskCubit, TaskState>(
                  builder: (context, state) {
                    if (state.status == TaskStatus.loading ||
                        state.status == TaskStatus.initial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == TaskStatus.error) {
                      return Center(
                        child: Text(state.errorMessage ?? l10n.loadingError),
                      );
                    }

                    final existingCategoryIds = {
                      for (final c in categoryState.categories) c.id,
                    };
                    final validSelectedIds = _selectedCategoryIds
                        .intersection(existingCategoryIds);
                    final validExcludedIds = _excludedCategoryIds
                        .intersection(existingCategoryIds);

                    var filtered = _showPostponed
                        ? state.postponedTasks
                        : validSelectedIds.isNotEmpty
                        ? state.tasks
                              .where(
                                (t) => validSelectedIds.contains(t.categoryId),
                              )
                              .toList()
                        : validExcludedIds.isEmpty
                        ? state.tasks
                        : state.tasks
                              .where(
                                (t) =>
                                    !validExcludedIds.contains(t.categoryId),
                              )
                              .toList();

                    if (_searchQuery.isNotEmpty) {
                      filtered = FuzzySearch.filter(
                        _searchQuery,
                        filtered,
                        (t) => [t.title, t.description],
                      );
                    }

                    final grid = _layoutMode == MatrixLayoutMode.grid
                        ? MatrixGrid(
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
                        : StackedMatrix(
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
    final result = await showModalBottomSheet<TaskFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => TaskFormSheet(
        categories: categories,
        existing: existing,
        inputMode: _taskInputMode,
      ),
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
        showFromDate: result.showFromDate,
        categoryId: result.categoryId,
      );
      return;
    }

    await context.read<TaskCubit>().updateTask(
      existing.copyWith(
        title: result.title,
        description: result.description,
        dueDate: result.dueDate,
        showFromDate: result.showFromDate,
        categoryId: result.categoryId,
        quadrant: result.quadrant,
        clearDescription: result.clearDescription,
        clearDueDate: result.clearDueDate,
        clearShowFromDate: result.clearShowFromDate,
        clearCategory: result.clearCategory,
      ),
    );
  }

  Future<void> _openCategoryManager(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const CategoryManagerModal(),
    );
  }

  @override
  void dispose() {
    _newTaskSubscription?.cancel();
    super.dispose();
  }
}
