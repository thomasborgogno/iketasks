import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../zaino_cubit.dart';
import '../zaino_state.dart';

/// Categories aren't a persisted entity — they're just the distinct
/// `categoryName` values across a zaino's items — so this sheet only offers
/// rename/delete on categories already in use; there's nothing to "add".
class ZainoCategorySheet extends StatefulWidget {
  const ZainoCategorySheet({super.key});

  @override
  State<ZainoCategorySheet> createState() => _ZainoCategorySheetState();
}

class _ZainoCategorySheetState extends State<ZainoCategorySheet> {
  final _editControllers = <String, TextEditingController>{};

  @override
  void dispose() {
    for (final c in _editControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _distinctCategories(ZainoDetailState state) {
    final seen = <String>{};
    final result = <String>[];
    for (final item in state.items) {
      final cat = item.categoryName;
      if (cat != null && cat.isNotEmpty && seen.add(cat)) {
        result.add(cat);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ZainoDetailCubit, ZainoDetailState>(
      builder: (context, state) {
        final categories = _distinctCategories(state);

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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Gestisci categorie',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (categories.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Nessuna categoria. Assegnane una a un elemento per '
                    'vederla qui.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...categories.map((cat) {
                  _editControllers.putIfAbsent(
                    cat,
                    () => TextEditingController(text: cat),
                  );
                  return _CategoryRow(
                    name: cat,
                    controller: _editControllers[cat]!,
                    onDelete: () =>
                        context.read<ZainoDetailCubit>().deleteCategory(cat),
                    onRename: (newName) => context
                        .read<ZainoDetailCubit>()
                        .renameCategory(cat, newName),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryRow extends StatefulWidget {
  const _CategoryRow({
    required this.name,
    required this.controller,
    required this.onDelete,
    required this.onRename,
  });

  final String name;
  final TextEditingController controller;
  final VoidCallback onDelete;
  final void Function(String) onRename;

  @override
  State<_CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<_CategoryRow> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              autofocus: true,
              decoration: const InputDecoration(isDense: true),
              onSubmitted: (v) {
                widget.onRename(v.trim());
                setState(() => _editing = false);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              widget.onRename(widget.controller.text.trim());
              setState(() => _editing = false);
            },
          ),
        ],
      );
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.category_outlined),
      title: Text(widget.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => setState(() => _editing = true),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}
