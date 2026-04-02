import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../tasks/presentation/task_cubit.dart';
import '../data/google_tasks_repository.dart';
import '../domain/google_task_item.dart';
import 'google_tasks_import_cubit.dart';
import 'quadrant_assignment_page.dart';

class GoogleTasksImportPage extends StatelessWidget {
  const GoogleTasksImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GoogleTasksImportCubit(context.read<GoogleTasksRepository>())
            ..loadTasks(),
      child: const _GoogleTasksImportBody(),
    );
  }
}

class _GoogleTasksImportBody extends StatelessWidget {
  const _GoogleTasksImportBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GoogleTasksImportCubit, GoogleTasksImportState>(
      listenWhen: (prev, curr) =>
          curr.status == GoogleTasksImportStatus.assigning &&
          prev.status != GoogleTasksImportStatus.assigning,
      listener: (context, state) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: context.read<GoogleTasksImportCubit>(),
              child: QuadrantAssignmentPage(
                tasks: context.read<GoogleTasksImportCubit>().state.selected,
                onConfirm: (assignments) async {
                  final taskCubit = context.read<TaskCubit>();
                  final selectedTasks = context
                      .read<GoogleTasksImportCubit>()
                      .state
                      .selected;
                  for (final entry in assignments.entries) {
                    final task = selectedTasks.firstWhere(
                      (t) => t.id == entry.key,
                    );
                    await taskCubit.createTask(
                      title: task.title,
                      quadrant: entry.value,
                      description: task.notes,
                      dueDate: task.due,
                    );
                  }
                  if (context.mounted) {
                    Navigator.of(context)
                      ..pop()
                      ..pop();
                  }
                },
              ),
            ),
          ),
        );
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Importa da Google Tasks')),
          body: _buildBody(context, state),
          floatingActionButton:
              state.status == GoogleTasksImportStatus.selecting &&
                  state.selected.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () => context
                      .read<GoogleTasksImportCubit>()
                      .proceedToAssignment(),
                  icon: const Icon(Icons.arrow_forward),
                  label: Text('Continua (${state.selected.length})'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, GoogleTasksImportState state) {
    switch (state.status) {
      case GoogleTasksImportStatus.initial:
      case GoogleTasksImportStatus.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Caricamento attività Google...'),
            ],
          ),
        );
      case GoogleTasksImportStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text(
                  state.errorMessage ?? 'Errore sconosciuto',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      context.read<GoogleTasksImportCubit>().loadTasks(),
                  child: const Text('Riprova'),
                ),
              ],
            ),
          ),
        );
      case GoogleTasksImportStatus.selecting:
      case GoogleTasksImportStatus.assigning:
        if (state.tasks.isEmpty) {
          return const Center(
            child: Text('Nessuna attività trovata su Google Tasks.'),
          );
        }
        return _TabbedTaskSelection(
          tasks: state.tasks,
          selected: state.selected,
        );
    }
  }
}

class _TabbedTaskSelection extends StatefulWidget {
  const _TabbedTaskSelection({required this.tasks, required this.selected});

  final List<GoogleTaskItem> tasks;
  final List<GoogleTaskItem> selected;

  @override
  State<_TabbedTaskSelection> createState() => _TabbedTaskSelectionState();
}

class _TabbedTaskSelectionState extends State<_TabbedTaskSelection>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final List<MapEntry<String, List<GoogleTaskItem>>> _sections;

  @override
  void initState() {
    super.initState();
    _sections = _buildSections(widget.tasks);
    _tabController = TabController(length: _sections.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<MapEntry<String, List<GoogleTaskItem>>> _buildSections(
    List<GoogleTaskItem> tasks,
  ) {
    final byList = <String, List<GoogleTaskItem>>{};
    for (final task in tasks) {
      (byList[task.taskListTitle] ??= []).add(task);
    }
    return byList.entries.toList();
  }

  @override
  void didUpdateWidget(_TabbedTaskSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Rebuild sections only if task list changed
    if (oldWidget.tasks != widget.tasks) {
      final newSections = _buildSections(widget.tasks);
      if (newSections.length != _sections.length) {
        _tabController.dispose();
        _sections
          ..clear()
          ..addAll(newSections);
        _tabController = TabController(length: _sections.length, vsync: this);
      } else {
        _sections
          ..clear()
          ..addAll(newSections);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: _sections.length > 2,
          tabs: _sections.map((s) => Tab(text: s.key)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _sections.map((section) {
              final listTasks = section.value;
              final allSelected = listTasks.every(
                (t) => widget.selected.any((s) => s.id == t.id),
              );
              return Column(
                children: [
                  CheckboxListTile(
                    value: allSelected,
                    tristate: false,
                    onChanged: (_) => context
                        .read<GoogleTasksImportCubit>()
                        .toggleSelectAll(listTasks),
                    title: Text(
                      allSelected ? 'Deseleziona tutto' : 'Seleziona tutto',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: listTasks.length,
                      itemBuilder: (context, index) {
                        final task = listTasks[index];
                        final isSelected = widget.selected.any(
                          (t) => t.id == task.id,
                        );
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (_) => context
                              .read<GoogleTasksImportCubit>()
                              .toggleSelection(task),
                          title: Text(task.title),
                          subtitle: task.notes != null && task.notes!.isNotEmpty
                              ? Text(
                                  task.notes!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          visualDensity: VisualDensity.compact,
                        );
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
