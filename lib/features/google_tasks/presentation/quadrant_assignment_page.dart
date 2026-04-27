import 'package:iketasks/features/tasks/presentation/helpers.dart';
import 'package:flutter/material.dart';
import 'package:iketasks/l10n/app_localizations.dart';

import '../domain/google_task_item.dart';

class QuadrantAssignmentPage extends StatefulWidget {
  const QuadrantAssignmentPage({
    super.key,
    required this.tasks,
    required this.onConfirm,
  });

  final List<GoogleTaskItem> tasks;
  final Future<void> Function(Map<String, EisenhowerQuadrant> assignments)
  onConfirm;

  @override
  State<QuadrantAssignmentPage> createState() => _QuadrantAssignmentPageState();
}

class _QuadrantAssignmentPageState extends State<QuadrantAssignmentPage> {
  final Map<String, EisenhowerQuadrant> _assignments = {};
  int _currentIndex = 0;
  bool _saving = false;

  GoogleTaskItem get _currentTask => widget.tasks[_currentIndex];

  bool get _isCurrentAssigned => _assignments.containsKey(_currentTask.id);

  bool get _allAssigned =>
      widget.tasks.every((t) => _assignments.containsKey(t.id));

  void _assign(EisenhowerQuadrant quadrant) {
    setState(() {
      _assignments[_currentTask.id] = quadrant;
      if (_currentIndex < widget.tasks.length - 1 && !_allAssigned) {
        // Advance to next unassigned task
        for (var i = _currentIndex + 1; i < widget.tasks.length; i++) {
          if (!_assignments.containsKey(widget.tasks[i].id)) {
            _currentIndex = i;
            break;
          }
        }
      }
    });
  }

  Widget _quadrantTarget(EisenhowerQuadrant quadrant) {
    final color = quadrantColor(quadrant);
    final assigned = _assignments[_currentTask.id] == quadrant;

    return Expanded(
      child: DragTarget<GoogleTaskItem>(
        onWillAcceptWithDetails: (_) => true,
        onAcceptWithDetails: (_) => _assign(quadrant),
        builder: (context, candidateData, _) {
          final isHovered = candidateData.isNotEmpty;
          return GestureDetector(
            onTap: () => _assign(quadrant),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: assigned
                    ? color.withValues(alpha: 0.35)
                    : isHovered
                    ? color.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withValues(alpha: assigned ? 0.9 : 0.4),
                  width: assigned ? 2 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  quadrant.importLabel(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: assigned ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final assignedCount = _assignments.length;
    final total = widget.tasks.length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.assignQuadrant(assignedCount, total))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress
            LinearProgressIndicator(value: assignedCount / total),
            const SizedBox(height: 16),

            // Task card (draggable)
            Draggable<GoogleTaskItem>(
              data: _currentTask,
              feedback: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: _TaskCard(task: _currentTask),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.35,
                child: _TaskCard(task: _currentTask),
              ),
              child: _TaskCard(task: _currentTask),
            ),

            const SizedBox(height: 8),
            Text(
              _isCurrentAssigned
                  ? l10n.quadrantAssigned
                  : l10n.dragOrTapQuadrant,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // 2x2 grid of targets
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _quadrantTarget(EisenhowerQuadrant.importantUrgent),
                        _quadrantTarget(EisenhowerQuadrant.importantNotUrgent),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        _quadrantTarget(EisenhowerQuadrant.notImportantUrgent),
                        _quadrantTarget(
                          EisenhowerQuadrant.notImportantNotUrgent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Navigation buttons
            Row(
              children: [
                if (_currentIndex > 0)
                  TextButton.icon(
                    onPressed: () => setState(() => _currentIndex--),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.previous),
                  ),
                const Spacer(),
                if (!_allAssigned && _currentIndex < total - 1)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        for (var i = _currentIndex + 1; i < total; i++) {
                          if (!_assignments.containsKey(widget.tasks[i].id)) {
                            _currentIndex = i;
                            break;
                          }
                        }
                      });
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(l10n.skip),
                  ),
                if (_allAssigned)
                  FilledButton.icon(
                    onPressed: _saving
                        ? null
                        : () async {
                            setState(() => _saving = true);
                            await widget.onConfirm(_assignments);
                          },
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(l10n.importTasks),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final GoogleTaskItem task;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (task.notes != null && task.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.notes!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (task.taskListTitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.list_alt_outlined, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    task.taskListTitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
