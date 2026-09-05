import 'package:flutter/material.dart';

import '../../../core/utils/fuzzy_search.dart';
import '../domain/eisenhower_quadrant.dart';
import '../domain/task_item.dart';

class TaskSearchDelegate extends SearchDelegate<TaskItem?> {
  TaskSearchDelegate({required this.tasks, required this.onTaskTap});

  final List<TaskItem> tasks;
  final ValueChanged<TaskItem> onTaskTap;

  @override
  String get searchFieldLabel => 'Cerca task…';

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final filtered = FuzzySearch.filter(
      query,
      tasks,
      (t) => [t.title, t.description],
    );
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'Nessun risultato',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final task = filtered[i];
        final theme = Theme.of(context);
        final color = quadrantColor(task.quadrant);
        return ListTile(
          leading: Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          title: _Highlighted(text: task.title, query: query),
          subtitle: task.description != null && task.description!.isNotEmpty
              ? Text(
                  task.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                )
              : null,
          trailing: task.completed
              ? Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: theme.colorScheme.outline,
                )
              : null,
          onTap: () {
            close(context, task);
            onTaskTap(task);
          },
        );
      },
    );
  }
}

class _Highlighted extends StatelessWidget {
  const _Highlighted({required this.text, required this.query});

  final String text;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) return Text(text);
    final lower = text.toLowerCase();
    final q = query.trim().toLowerCase().split(RegExp(r'\s+')).first;
    final idx = lower.indexOf(q);
    if (idx < 0) return Text(text);

    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + q.length),
            style: TextStyle(
              backgroundColor:
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(idx + q.length)),
        ],
      ),
    );
  }
}
