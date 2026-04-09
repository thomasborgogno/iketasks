part of 'matrix_page.dart';

class _TaskFormResult {
  const _TaskFormResult({
    required this.title,
    required this.quadrant,
    required this.description,
    required this.dueDate,
    required this.categoryId,
    required this.clearDescription,
    required this.clearDueDate,
    required this.clearCategory,
  });

  final String title;
  final String? description;
  final DateTime? dueDate;
  final String? categoryId;
  final EisenhowerQuadrant quadrant;
  final bool clearDescription;
  final bool clearDueDate;
  final bool clearCategory;
}

class _TaskForm extends StatefulWidget {
  const _TaskForm({required this.categories, this.existing});

  final List<TaskCategory> categories;
  final TaskItem? existing;

  @override
  State<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<_TaskForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final FocusNode _descriptionFocusNode = FocusNode();
  late EisenhowerQuadrant _quadrant;
  late bool _isImportant;
  late bool _isUrgent;
  DateTime? _dueDate;
  String? _categoryId;
  bool _showDescription = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title);
    _descriptionController = TextEditingController(
      text: widget.existing?.description,
    );
    _quadrant = widget.existing?.quadrant ?? EisenhowerQuadrant.importantUrgent;
    _syncFlagsFromQuadrant(_quadrant);
    _dueDate = widget.existing?.dueDate;
    _categoryId = widget.existing?.categoryId;
    _showDescription =
        widget.existing?.description != null &&
        widget.existing!.description!.isNotEmpty;
  }

  void _syncFlagsFromQuadrant(EisenhowerQuadrant quadrant) {
    switch (quadrant) {
      case EisenhowerQuadrant.importantUrgent:
        _isImportant = true;
        _isUrgent = true;
      case EisenhowerQuadrant.importantNotUrgent:
        _isImportant = true;
        _isUrgent = false;
      case EisenhowerQuadrant.notImportantUrgent:
        _isImportant = false;
        _isUrgent = true;
      case EisenhowerQuadrant.notImportantNotUrgent:
        _isImportant = false;
        _isUrgent = false;
    }
  }

  void _syncQuadrantFromFlags() {
    if (_isImportant && _isUrgent) {
      _quadrant = EisenhowerQuadrant.importantUrgent;
      return;
    }
    if (_isImportant && !_isUrgent) {
      _quadrant = EisenhowerQuadrant.importantNotUrgent;
      return;
    }
    if (!_isImportant && _isUrgent) {
      _quadrant = EisenhowerQuadrant.notImportantUrgent;
      return;
    }
    _quadrant = EisenhowerQuadrant.notImportantNotUrgent;
  }

  Widget _quadrantChoiceChip(EisenhowerQuadrant quadrant) {
    final chipColor = quadrantColor(quadrant);
    final selected = _quadrant == quadrant;

    return ChoiceChip(
      label: SizedBox(
        width: double.infinity,
        child: Text(quadrant.name(context), textAlign: TextAlign.center),
      ),
      selected: selected,
      color: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return chipColor.withValues(alpha: 0.5);
        }
        return chipColor.withValues(alpha: 0.10);
      }),
      side: BorderSide(
        color: chipColor.withValues(alpha: selected ? 0.95 : 0.45),
      ),
      showCheckmark: false,
      onSelected: (isSelected) {
        if (!isSelected) return;
        setState(() {
          _quadrant = quadrant;
          _syncFlagsFromQuadrant(_quadrant);
        });
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _deleteExistingTask() async {
    final task = widget.existing;
    if (task == null) return;

    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteTask),
          content: Text(l10n.deleteTaskConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    await context.read<TaskCubit>().deleteTask(task.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEdit ? l10n.editTask : l10n.newTask,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.taskTitle),
              autofocus: !isEdit,
            ),
            if (_showDescription) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                focusNode: _descriptionFocusNode,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l10n.taskDescription),
              ),
            ],
            const SizedBox(height: 16),
            Text(l10n.priority, style: Theme.of(context).textTheme.labelMedium),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: Text(l10n.important),
                    selected: _isImportant,
                    onSelected: (value) {
                      setState(() {
                        _isImportant = value;
                        _syncQuadrantFromFlags();
                      });
                    },
                  ),
                  FilterChip(
                    label: Text(l10n.urgent),
                    selected: _isUrgent,
                    onSelected: (value) {
                      setState(() {
                        _isUrgent = value;
                        _syncQuadrantFromFlags();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Text(l10n.quadrant, style: Theme.of(context).textTheme.labelMedium),
            Column(
              children: [
                for (
                  var rowIndex = 0;
                  rowIndex < _matrixQuadrantRows.length;
                  rowIndex++
                )
                  Row(
                    children: [
                      for (
                        var columnIndex = 0;
                        columnIndex < _matrixQuadrantRows[rowIndex].length;
                        columnIndex++
                      ) ...[
                        if (columnIndex > 0) const SizedBox(width: 8),
                        Expanded(
                          child: _quadrantChoiceChip(
                            _matrixQuadrantRows[rowIndex][columnIndex],
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.category, style: Theme.of(context).textTheme.labelMedium),
            BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, categoryState) {
                final categories = categoryState.categories;
                if (categories.isEmpty) {
                  return TextButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const _CategoryManagerDialog(),
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.createCategory),
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...categories.map((c) {
                      final label = c.emoji != null && c.emoji!.isNotEmpty
                          ? '${c.emoji} ${c.name}'
                          : c.name;
                      return ChoiceChip(
                        label: Text(label),
                        selected: _categoryId == c.id,
                        onSelected: (_) => setState(
                          () => _categoryId = _categoryId == c.id ? null : c.id,
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            if (_dueDate != null) ...[
              Text(l10n.dueDate, style: Theme.of(context).textTheme.labelMedium),
              Text(DateFormat('dd/MM/yyyy').format(_dueDate!)),
              const SizedBox(height: 12),
            ],

            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notes,
                    color: _showDescription
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  tooltip: l10n.taskDescription,
                  onPressed: () async {
                    if (_showDescription &&
                        _descriptionController.text.trim().isNotEmpty) {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.removeDescription),
                          content: Text(l10n.removeDescriptionConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(l10n.cancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text(l10n.remove),
                            ),
                          ],
                        ),
                      );
                      if (confirm != true) return;
                      _descriptionController.clear();
                    }
                    setState(() => _showDescription = !_showDescription);
                    if (_showDescription) {
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _descriptionFocusNode.requestFocus(),
                      );
                    }
                  },
                ),
                IconButton(
                  iconSize: 20,
                  icon: Icon(
                    Icons.calendar_today,
                    color: _dueDate != null
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  tooltip: l10n.dueDate,
                  onPressed: () async {
                    if (_dueDate != null) {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.removeDueDate),
                          content: Text(l10n.removeDueDateConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(l10n.cancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text(l10n.remove),
                            ),
                          ],
                        ),
                      );
                      if (confirm != true) return;
                      setState(() => _dueDate = null);
                      return;
                    }
                    if (!mounted) return;
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _dueDate = picked);
                  },
                ),
                const SizedBox(width: 8),
                if (isEdit) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _deleteExistingTask,
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.delete),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      final title = _titleController.text.trim();
                      if (title.isEmpty) return;

                      Navigator.pop(
                        context,
                        _TaskFormResult(
                          title: title,
                          quadrant: _quadrant,
                          description:
                              _descriptionController.text.trim().isEmpty
                              ? null
                              : _descriptionController.text.trim(),
                          dueDate: _dueDate,
                          categoryId: _categoryId,
                          clearDescription: _descriptionController.text
                              .trim()
                              .isEmpty,
                          clearDueDate: _dueDate == null,
                          clearCategory: _categoryId == null,
                        ),
                      );
                    },
                    label: Text(isEdit ? l10n.save : l10n.createTask),
                    icon: const Icon(Icons.save_outlined),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
