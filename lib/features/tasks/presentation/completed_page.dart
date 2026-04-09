import 'package:eisenhower_matrix_app/features/tasks/presentation/task_completion_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../data/task_repository.dart';
import '../domain/task_item.dart';
import 'completed_tasks_cubit.dart';

class CompletedPage extends StatelessWidget {
  const CompletedPage({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CompletedTasksCubit(context.read<TaskRepository>())..bind(uid),
      child: const _CompletedPageBody(),
    );
  }
}

class _CompletedPageBody extends StatelessWidget {
  const _CompletedPageBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.completedTasks)),
      body: BlocBuilder<CompletedTasksCubit, CompletedTasksState>(
        builder: (context, state) {
          if (state.status == CompletedTasksStatus.initial ||
              state.status == CompletedTasksStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == CompletedTasksStatus.error) {
            return Center(
              child: Text(state.errorMessage ?? l10n.loadingError),
            );
          }
          if (state.tasks.isEmpty) {
            return Center(child: Text(l10n.noCompletedTasks));
          }
          return _CompletedTasksList(tasks: state.tasks);
        },
      ),
    );
  }
}

class _CompletedTasksList extends StatelessWidget {
  const _CompletedTasksList({required this.tasks});

  final List<TaskItem> tasks;

  List<({String monthLabel, List<TaskItem> tasks})> _groupByMonth(
    List<TaskItem> tasks,
    BuildContext context,
  ) {
    final locale = Localizations.localeOf(context);
    final formatter = DateFormat('MMMM yyyy', locale.toString());
    final groups = <String, List<TaskItem>>{};
    for (final task in tasks) {
      final key = formatter.format(task.updatedAt);
      (groups[key] ??= []).add(task);
    }
    return groups.entries
        .map((e) => (monthLabel: e.key, tasks: e.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupByMonth(tasks, context);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
      itemCount: groups.fold<int>(0, (sum, g) => sum + 1 + g.tasks.length),
      itemBuilder: (context, index) {
        var offset = 0;
        for (final group in groups) {
          if (index == offset) {
            return _MonthHeader(label: group.monthLabel);
          }
          offset++;
          final taskIndex = index - offset;
          if (taskIndex < group.tasks.length) {
            return _CompletedTaskTile(task: group.tasks[taskIndex]);
          }
          offset += group.tasks.length;
        }
        return null;
      },
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
      child: Text(
        label[0].toUpperCase() + label.substring(1),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CompletedTaskTile extends StatelessWidget {
  const _CompletedTaskTile({required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final updatedStr = DateFormat('dd/MM/yyyy', locale.toString()).format(task.updatedAt);
    return ListTile(
      leading: TaskCompletionCircle(
        completed: true,
        onTap: () => context.read<CompletedTasksCubit>().uncompleteTask(task),
      ),
      title: Text(
        task.title,
        style: const TextStyle(decoration: TextDecoration.lineThrough),
      ),
      subtitle: Text(l10n.completedOn(updatedStr)),
      dense: true,
    );
  }
}
