import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/zaino_item.dart';
import '../../domain/zaino_tag.dart';
import '../zaino_cubit.dart';

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
  late String? _selectedCategory;
  late Set<String> _selectedTags;

  /// Categories created via the "+" chip during this session, not yet
  /// reflected in [ZainoItemFormSheet.categories] (which is a snapshot taken
  /// when the sheet was opened).
  final Set<String> _extraCategories = {};

  /// Tag names created via the "+" chip during this session, mirroring
  /// [_extraCategories] — the corresponding [ZainoTag] is persisted right
  /// away, but this sheet isn't a BlocBuilder so it won't see it until then.
  final Set<String> _extraTagNames = {};

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _selectedCategory = widget.item?.categoryName;
    _selectedTags = Set<String>.from(widget.item?.tags ?? []);
    if (_selectedCategory != null &&
        !widget.categories.contains(_selectedCategory)) {
      _extraCategories.add(_selectedCategory!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    Navigator.of(context).pop({
      'title': title,
      'categoryName': _selectedCategory,
      'tags': _selectedTags.toList(),
    });
  }

  Future<void> _addCategory() async {
    final name = await _promptForName(
      title: 'Nuova categoria',
      label: 'Nome categoria',
    );
    if (name == null || name.isEmpty || !mounted) return;
    setState(() {
      if (!widget.categories.contains(name)) _extraCategories.add(name);
      _selectedCategory = name;
    });
  }

  Future<void> _addTag() async {
    final name = await _promptForName(title: 'Nuovo tag', label: 'Nome tag');
    if (name == null || name.isEmpty || !mounted) return;
    final alreadyExists = widget.tags.any((t) => t.name == name);
    if (!alreadyExists) {
      await context.read<ZainoDetailCubit>().createTag(name);
    }
    if (!mounted) return;
    setState(() {
      if (!alreadyExists) _extraTagNames.add(name);
      _selectedTags.add(name);
    });
  }

  Future<String?> _promptForName({
    required String title,
    required String label,
  }) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: label),
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Crea'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.item != null;
    final categories = [...widget.categories, ..._extraCategories];
    final tagNames = [...widget.tags.map((t) => t.name), ..._extraTagNames];

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
          const SizedBox(height: 16),
          Text('Categoria', style: theme.textTheme.labelLarge),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final cat in categories)
                ChoiceChip(
                  label: Text(cat),
                  selected: _selectedCategory == cat,
                  onSelected: (v) =>
                      setState(() => _selectedCategory = v ? cat : null),
                ),
              ActionChip(
                label: const Icon(Icons.add, size: 18),
                onPressed: _addCategory,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Tag', style: theme.textTheme.labelLarge),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final name in tagNames)
                FilterChip(
                  label: Text(name),
                  selected: _selectedTags.contains(name),
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _selectedTags.add(name);
                      } else {
                        _selectedTags.remove(name);
                      }
                    });
                  },
                ),
              ActionChip(
                label: const Icon(Icons.add, size: 18),
                onPressed: _addTag,
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _submit,
            child: Text(isEdit ? 'Salva' : 'Aggiungi'),
          ),
        ],
      ),
    );
  }
}
