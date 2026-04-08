part of 'matrix_page.dart';

// ---------------------------------------------------------------------------
// Profile widgets
// ---------------------------------------------------------------------------

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, this.onLogout});

  final User user;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final name = user.displayName?.trim();
    final email = user.email?.trim();
    return Row(
      children: [
        _ProfileAvatar(photoUrl: user.photoURL, radius: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (name == null || name.isEmpty) ? 'Utente Google' : name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (email != null && email.isNotEmpty)
                Text(email, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        if (onLogout != null)
          IconButton(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Esci',
          ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photoUrl, this.radius = 18});

  final String? photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final validPhotoUrl = photoUrl != null && photoUrl!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      foregroundImage: validPhotoUrl ? NetworkImage(photoUrl!) : null,
      child: validPhotoUrl
          ? null
          : Icon(
              Icons.person,
              size: radius,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category manager dialog
// ---------------------------------------------------------------------------

class _CategoryManagerDialog extends StatefulWidget {
  const _CategoryManagerDialog();

  @override
  State<_CategoryManagerDialog> createState() => _CategoryManagerDialogState();
}

class _CategoryManagerDialogState extends State<_CategoryManagerDialog> {
  late final TextEditingController _controller;
  late final TextEditingController _emojiController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _emojiController = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    final emoji = _emojiController.text.trim();
    await context.read<CategoryCubit>().createCategory(
      name,
      emoji: emoji.isEmpty ? null : emoji,
    );
    if (!mounted) return;
    _controller.clear();
    _emojiController.clear();
  }

  Future<void> _confirmDelete(TaskCategory category) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Elimina categoria'),
        content: Text(
          'Eliminare "${category.name}"?\n'
          'Le attività associate perderanno la categoria.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(d).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(d).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;
    await context.read<CategoryCubit>().deleteCategory(category.id);
  }

  void _closeDialog() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gestione categorie'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 64,
                  child: TextField(
                    controller: _emojiController,
                    decoration: const InputDecoration(labelText: 'Emoji'),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Nome categoria',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _addCategory(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _addCategory,
              child: const Text('Aggiungi'),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, state) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      return ListTile(
                        dense: true,
                        leading:
                            category.emoji != null && category.emoji!.isNotEmpty
                            ? Text(
                                category.emoji!,
                                style: const TextStyle(fontSize: 20),
                              )
                            : null,
                        title: Text(category.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDelete(category),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _closeDialog, child: const Text('Chiudi')),
      ],
    );
  }
}
