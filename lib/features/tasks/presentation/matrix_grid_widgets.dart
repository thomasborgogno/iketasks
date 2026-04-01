part of 'matrix_page.dart';

class _QuadrantCard extends StatelessWidget {
  const _QuadrantCard({
    required this.quadrant,
    required this.tasks,
    required this.onToggle,
    required this.onTaskTap,
    required this.onTaskMove,
  });

  final EisenhowerQuadrant quadrant;
  final List<TaskItem> tasks;
  final ValueChanged<TaskItem> onToggle;
  final ValueChanged<TaskItem> onTaskTap;
  final void Function(TaskItem task, EisenhowerQuadrant targetQuadrant)
  onTaskMove;

  @override
  Widget build(BuildContext context) {
    final color = _quadrantColor(quadrant);
    return DragTarget<TaskItem>(
      onWillAcceptWithDetails: (details) => details.data.quadrant != quadrant,
      onAcceptWithDetails: (details) => onTaskMove(details.data, quadrant),
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withValues(alpha: isActive ? 0.75 : 0.4),
                  width: isActive ? 2 : 1.2,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: isActive ? 0.2 : 0.12),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
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
                                  onToggle: () => onToggle(task),
                                  onTap: () => onTaskTap(task),
                                );
                              },
                            ),
                    ),
                  ],
                ),
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
    required this.onToggleTask,
    required this.onTaskTap,
    required this.onTaskMove,
  });

  final List<TaskItem> tasks;
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

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  final TaskItem task;
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
