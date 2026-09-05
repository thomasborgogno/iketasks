import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/zaino_tag.dart';
import '../zaino_cubit.dart';
import '../zaino_state.dart';

class ZainoTagSheet extends StatefulWidget {
  const ZainoTagSheet({super.key});

  @override
  State<ZainoTagSheet> createState() => _ZainoTagSheetState();
}

class _ZainoTagSheetState extends State<ZainoTagSheet> {
  final _newTagController = TextEditingController();
  final _editControllers = <String, TextEditingController>{};

  @override
  void dispose() {
    _newTagController.dispose();
    for (final c in _editControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ZainoDetailCubit, ZainoDetailState>(
      builder: (context, state) {
        final tags = state.tags;

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
                    child: Text('Gestisci tag', style: theme.textTheme.titleLarge),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (tags.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Nessun tag. Aggiungine uno per filtrare gli elementi.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...tags.map((tag) {
                  _editControllers.putIfAbsent(
                    tag.id,
                    () => TextEditingController(text: tag.name),
                  );
                  return _TagRow(
                    tag: tag,
                    controller: _editControllers[tag.id]!,
                    onDelete: () =>
                        context.read<ZainoDetailCubit>().deleteTag(tag),
                    onRename: (name) =>
                        context.read<ZainoDetailCubit>().updateTag(tag, name),
                  );
                }),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newTagController,
                      decoration: const InputDecoration(
                        hintText: 'Nuovo tag...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _addTag(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _addTag(context),
                    child: const Text('Aggiungi'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _addTag(BuildContext context) {
    final name = _newTagController.text.trim();
    if (name.isEmpty) return;
    context.read<ZainoDetailCubit>().createTag(name);
    _newTagController.clear();
  }
}

class _TagRow extends StatefulWidget {
  const _TagRow({
    required this.tag,
    required this.controller,
    required this.onDelete,
    required this.onRename,
  });

  final ZainoTag tag;
  final TextEditingController controller;
  final VoidCallback onDelete;
  final void Function(String) onRename;

  @override
  State<_TagRow> createState() => _TagRowState();
}

class _TagRowState extends State<_TagRow> {
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
      leading: const Icon(Icons.label_outline),
      title: Text(widget.tag.name),
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
