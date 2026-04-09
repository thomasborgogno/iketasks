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
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _ProfileAvatar(photoUrl: user.photoURL, radius: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (name == null || name.isEmpty) ? l10n.googleUser : name,
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
            tooltip: l10n.signOut,
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
// Category manager modal
// ---------------------------------------------------------------------------

class _CategoryManagerModal extends StatefulWidget {
  const _CategoryManagerModal();

  @override
  State<_CategoryManagerModal> createState() => _CategoryManagerModalState();
}

class _CategoryManagerModalState extends State<_CategoryManagerModal> {
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
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(
          l10n.deleteCategoryConfirm(category.name) + '\n' +
          l10n.deleteCategoryWarning,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(d).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(d).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;
    await context.read<CategoryCubit>().deleteCategory(category.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.categoryManagement,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 64,
                child: TextField(
                  controller: _emojiController,
                  decoration: InputDecoration(
                    labelText: l10n.emoji,
                    border: const OutlineInputBorder(),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: l10n.categoryName,
                    border: const OutlineInputBorder(),
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
            child: Text(l10n.add),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) {
                if (state.categories.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      l10n.onboardingNoCategoriesYet,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
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
    );
  }
}

// ---------------------------------------------------------------------------
// Language option widget
// ---------------------------------------------------------------------------

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.languageName,
    required this.locale,
    required this.currentLocale,
  });

  final String languageName;
  final Locale locale;
  final Locale? currentLocale;

  @override
  Widget build(BuildContext context) {
    final isSelected = currentLocale?.languageCode == locale.languageCode;

    return ListTile(
      title: Text(languageName),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () async {
        await context.read<LocaleCubit>().changeLocale(locale);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
