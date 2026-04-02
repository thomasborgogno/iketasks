part of 'matrix_page.dart';

class _QuadrantCard extends StatelessWidget {
  const _QuadrantCard({
    required this.quadrant,
    required this.tasks,
    required this.categoryEmojiMap,
    required this.onToggle,
    required this.onTaskTap,
    required this.onTaskMove,
    this.scrollable = true,
  });

  final EisenhowerQuadrant quadrant;
  final List<TaskItem> tasks;
  final Map<String, String>? categoryEmojiMap;
  final ValueChanged<TaskItem> onToggle;
  final ValueChanged<TaskItem> onTaskTap;
  final void Function(TaskItem task, EisenhowerQuadrant targetQuadrant)
  onTaskMove;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final color = _quadrantColor(quadrant);
    final radius = BorderRadius.circular(26);
    return DragTarget<TaskItem>(
      onWillAcceptWithDetails: (details) => details.data.quadrant != quadrant,
      onAcceptWithDetails: (details) => onTaskMove(details.data, quadrant),
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: radius),
            color: isActive ? color.withValues(alpha: 0.001) : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      quadrant.cardTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quadrant.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (scrollable)
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
                                  categoryEmoji:
                                      task.categoryId != null &&
                                          categoryEmojiMap != null
                                      ? categoryEmojiMap![task.categoryId]
                                      : null,
                                  onToggle: () => onToggle(task),
                                  onTap: () => onTaskTap(task),
                                );
                              },
                            ),
                    )
                  else if (tasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: Text(
                          'Vuoto',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: tasks.map((task) {
                        return _TaskTile(
                          task: task,
                          categoryEmoji:
                              task.categoryId != null &&
                                  categoryEmojiMap != null
                              ? categoryEmojiMap![task.categoryId]
                              : null,
                          onToggle: () => onToggle(task),
                          onTap: () => onTaskTap(task),
                        );
                      }).toList(),
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

class _MatrixGrid extends StatelessWidget {
  const _MatrixGrid({
    required this.tasks,
    required this.categoryEmojiMap,
    required this.onToggleTask,
    required this.onTaskTap,
    required this.onTaskMove,
  });

  final List<TaskItem> tasks;
  final Map<String, String>? categoryEmojiMap;
  final ValueChanged<TaskItem> onToggleTask;
  final ValueChanged<TaskItem> onTaskTap;
  final void Function(TaskItem task, EisenhowerQuadrant targetQuadrant)
  onTaskMove;

  List<TaskItem> _tasksFor(EisenhowerQuadrant quadrant) {
    return tasks.where((task) => task.quadrant == quadrant).toList();
  }

  @override
  Widget build(BuildContext context) {
    const cardSpacing = 8.0;
    return Column(
      children: [
        for (
          var rowIndex = 0;
          rowIndex < _matrixQuadrantRows.length;
          rowIndex++
        ) ...[
          Expanded(
            child: Row(
              children: [
                for (
                  var columnIndex = 0;
                  columnIndex < _matrixQuadrantRows[rowIndex].length;
                  columnIndex++
                ) ...[
                  if (columnIndex > 0) const SizedBox(width: cardSpacing),
                  Expanded(
                    child: _QuadrantCard(
                      quadrant: _matrixQuadrantRows[rowIndex][columnIndex],
                      tasks: _tasksFor(
                        _matrixQuadrantRows[rowIndex][columnIndex],
                      ),
                      categoryEmojiMap: categoryEmojiMap,
                      onToggle: onToggleTask,
                      onTaskTap: onTaskTap,
                      onTaskMove: onTaskMove,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (rowIndex < _matrixQuadrantRows.length - 1)
            const SizedBox(height: cardSpacing),
        ],
      ],
    );
  }
}

class _StackedMatrix extends StatelessWidget {
  const _StackedMatrix({
    required this.tasks,
    required this.categoryEmojiMap,
    required this.onToggleTask,
    required this.onTaskTap,
    required this.onTaskMove,
  });

  final List<TaskItem> tasks;
  final Map<String, String>? categoryEmojiMap;
  final ValueChanged<TaskItem> onToggleTask;
  final ValueChanged<TaskItem> onTaskTap;
  final void Function(TaskItem task, EisenhowerQuadrant targetQuadrant)
  onTaskMove;

  List<TaskItem> _tasksFor(EisenhowerQuadrant quadrant) {
    return tasks.where((task) => task.quadrant == quadrant).toList();
  }

  @override
  Widget build(BuildContext context) {
    const cardSpacing = 8.0;
    final quadrants = [
      EisenhowerQuadrant.importantUrgent,
      EisenhowerQuadrant.importantNotUrgent,
      EisenhowerQuadrant.notImportantUrgent,
      EisenhowerQuadrant.notImportantNotUrgent,
    ];
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: quadrants.length,
      separatorBuilder: (_, _) => const SizedBox(height: cardSpacing),
      itemBuilder: (context, index) {
        final quadrant = quadrants[index];
        return _QuadrantCard(
          quadrant: quadrant,
          tasks: _tasksFor(quadrant),
          categoryEmojiMap: categoryEmojiMap,
          onToggle: onToggleTask,
          onTaskTap: onTaskTap,
          onTaskMove: onTaskMove,
          scrollable: false,
        );
      },
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onTap,
    this.categoryEmoji,
  });

  final TaskItem task;
  final String? categoryEmoji;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final due = task.dueDate == null
        ? null
        : DateFormat('dd/MM/yyyy').format(task.dueDate!);
    final tile = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: ListTile(
            dense: true,
            visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 0,
            ),
            horizontalTitleGap: 8,
            leading: TaskCompletionCircle(
              completed: task.completed,
              categoryEmoji: categoryEmoji,
              onTap: onToggle,
            ),
            title: Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                height: 1.2,
                decoration: task.completed ? TextDecoration.lineThrough : null,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: due == null ? null : Text('Scadenza: $due'),
          ),
        ),
      ),
    );

    return LongPressDraggable<TaskItem>(
      data: task,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: _DraggedTaskPreview(task: task),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: tile),
      child: tile,
    );
  }
}

class _DraggedTaskPreview extends StatelessWidget {
  const _DraggedTaskPreview({required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(
        task.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
