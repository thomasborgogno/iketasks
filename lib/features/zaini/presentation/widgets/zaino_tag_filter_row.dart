import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../zaino_detail_cubit.dart';
import '../zaino_state.dart';

/// Centered row of tag filter chips at the top of the item list, plus a "+"
/// chip to create a new tag on the spot.
class ZainoTagFilterRow extends StatelessWidget {
  const ZainoTagFilterRow({super.key, required this.state});

  final ZainoDetailState state;

  Future<void> _addTag(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuovo tag'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Nome tag'),
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
    if (name == null || name.isEmpty || !context.mounted) return;
    await context.read<ZainoDetailCubit>().createTag(name);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final tag in state.tags)
          FilterChip(
            label: Text(tag.name),
            selected: state.activeTagFilter.contains(tag.name),
            onSelected: (v) {
              final current = List<String>.from(state.activeTagFilter);
              if (v) {
                current.add(tag.name);
              } else {
                current.remove(tag.name);
              }
              context.read<ZainoDetailCubit>().setTagFilter(current);
            },
          ),
        ActionChip(
          label: const Icon(Icons.add, size: 18),
          onPressed: () => _addTag(context),
        ),
      ],
    );
  }
}
