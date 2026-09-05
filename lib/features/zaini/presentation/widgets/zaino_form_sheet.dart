import 'package:flutter/material.dart';

class ZainoFormSheet extends StatefulWidget {
  const ZainoFormSheet({super.key, this.initialName, this.initialEmoji});

  final String? initialName;
  final String? initialEmoji;

  @override
  State<ZainoFormSheet> createState() => _ZainoFormSheetState();
}

class _ZainoFormSheetState extends State<ZainoFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _emojiController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _emojiController = TextEditingController(text: widget.initialEmoji ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop({
      'name': name,
      'emoji': _emojiController.text.trim().isEmpty
          ? null
          : _emojiController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.initialName != null;

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
            isEdit ? 'Modifica zaino' : 'Nuovo zaino',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                child: TextField(
                  controller: _emojiController,
                  decoration: const InputDecoration(
                    labelText: 'Icona',
                    hintText: '🎒',
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 28),
                  textAlign: TextAlign.center,
                  maxLength: 2,
                  buildCounter: (_, {required count, required isFocused, maxLength}) =>
                      const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome zaino',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  autofocus: widget.initialName == null,
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submit,
            child: Text(isEdit ? 'Salva' : 'Crea'),
          ),
        ],
      ),
    );
  }
}
