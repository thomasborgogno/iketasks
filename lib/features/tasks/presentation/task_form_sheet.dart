part of 'matrix_page.dart';

class _TaskFormResult {
  const _TaskFormResult({
    required this.title,
    required this.quadrant,
    required this.description,
    required this.dueDate,
    required this.categoryId,
    required this.clearDueDate,
    required this.clearCategory,
  });

  final String title;
  final String? description;
  final DateTime? dueDate;
  final String? categoryId;
  final EisenhowerQuadrant quadrant;
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
  late EisenhowerQuadrant _quadrant;
  late bool _isImportant;
  late bool _isUrgent;
  DateTime? _dueDate;
  String? _categoryId;

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
    final chipColor = _quadrantColor(quadrant);
    final selected = _quadrant == quadrant;

    return ChoiceChip(
      label: SizedBox(
        width: double.infinity,
        child: Text(quadrant.cardTitle, textAlign: TextAlign.center),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
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
              isEdit ? 'Modifica task' : 'Nuova task',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titolo *'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrizione'),
            ),
            const SizedBox(height: 16),
            Text('Priorità', style: Theme.of(context).textTheme.labelMedium),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Importante'),
                    selected: _isImportant,
                    onSelected: (value) {
                      setState(() {
                        _isImportant = value;
                        _syncQuadrantFromFlags();
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Urgente'),
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
            const SizedBox(height: 16),

            Text('Quadrante', style: Theme.of(context).textTheme.labelMedium),
            Column(
              children: [
                for (
                  var rowIndex = 0;
                  rowIndex < _matrixQuadrantRows.length;
                  rowIndex++
                )
                  Padding(
                    padding: EdgeInsets.only(top: rowIndex == 0 ? 0 : 8),
                    child: Row(
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
                  ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: _categoryId,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Nessuna categoria'),
                ),
                ...widget.categories.map(
                  (c) => DropdownMenuItem<String?>(
                    value: c.id,
                    child: Text(c.name),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dueDate == null
                        ? 'Scadenza'
                        : 'Scadenza: ${DateFormat('dd/MM/yyyy').format(_dueDate!)}',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: _dueDate ?? DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _dueDate = picked);
                    }
                  },
                  child: const Text('Seleziona data'),
                ),
                if (_dueDate != null)
                  IconButton(
                    onPressed: () => setState(() => _dueDate = null),
                    icon: const Icon(Icons.clear),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final title = _titleController.text.trim();
                if (title.isEmpty) return;

                Navigator.pop(
                  context,
                  _TaskFormResult(
                    title: title,
                    quadrant: _quadrant,
                    description: _descriptionController.text.trim().isEmpty
                        ? null
                        : _descriptionController.text.trim(),
                    dueDate: _dueDate,
                    categoryId: _categoryId,
                    clearDueDate: _dueDate == null,
                    clearCategory: _categoryId == null,
                  ),
                );
              },
              child: Text(isEdit ? 'Salva modifiche' : 'Crea task'),
            ),
          ],
        ),
      ),
    );
  }
}
