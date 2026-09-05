import 'package:flutter/material.dart';

import '../../domain/zaino_item.dart';
import '../../domain/zaino_tag.dart';

class ZainoItemFormSheet extends StatefulWidget {
  const ZainoItemFormSheet({
    super.key,
    required this.tags,
    required this.categories,
    this.item,
  });

  final List<ZainoTag> tags;
  final List<String> categories;
  final ZainoItem? item;

  @override
  State<ZainoItemFormSheet> createState() => _ZainoItemFormSheetState();
}

class _ZainoItemFormSheetState extends State<ZainoItemFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late Set<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _categoryController = TextEditingController(
      text: widget.item?.categoryName ?? '',
    );
    _selectedTags = Set<String>.from(widget.item?.tags ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final category = _categoryController.text.trim();
    Navigator.of(context).pop({
      'title': title,
      'categoryName': category.isEmpty ? null : category,
      'tags': _selectedTags.toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.item != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEdit ? 'Modifica elemento' : 'Nuovo elemento',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Elemento',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(
              labelText: 'Categoria (raggruppamento)',
              hintText: 'es. Abbigliamento',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          if (widget.categories.isNotEmpty) ...[
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.categories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ActionChip(
                      label: Text(cat, style: const TextStyle(fontSize: 12)),
                      onPressed: () => setState(() {
                        _categoryController.text = cat;
                      }),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (widget.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Tag', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: widget.tags.map((tag) {
                final selected = _selectedTags.contains(tag.name);
                return FilterChip(
                  label: Text(tag.name),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _selectedTags.add(tag.name);
                      } else {
                        _selectedTags.remove(tag.name);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submit,
            child: Text(isEdit ? 'Salva' : 'Aggiungi'),
          ),
        ],
      ),
    );
  }
}
