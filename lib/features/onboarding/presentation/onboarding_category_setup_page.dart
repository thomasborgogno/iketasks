import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iketasks/l10n/app_localizations.dart';
import 'package:iketasks/features/categories/presentation/category_cubit.dart';

class OnboardingCategorySetupPage extends StatefulWidget {
  const OnboardingCategorySetupPage({
    super.key,
    required this.onComplete,
    required this.onPrevious,
  });

  final VoidCallback onComplete;
  final VoidCallback onPrevious;

  @override
  State<OnboardingCategorySetupPage> createState() =>
      _OnboardingCategorySetupPageState();
}

class _OnboardingCategorySetupPageState
    extends State<OnboardingCategorySetupPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openCategoryCreation() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _CategoryCreationModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      Icons.category,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    Column(
                      children: [
                        Text(
                          l10n.onboardingCategoriesTitle,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.onboardingCategoriesDescription,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    BlocBuilder<CategoryCubit, CategoryState>(
                      builder: (context, state) {
                        if (state.status == CategoryStatus.loaded &&
                            state.categories.isNotEmpty) {
                          return Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: state.categories.length,
                              itemBuilder: (context, index) {
                                final category = state.categories[index];
                                return ListTile(
                                  leading:
                                      category.emoji != null &&
                                          category.emoji!.isNotEmpty
                                      ? Text(
                                          category.emoji!,
                                          style: const TextStyle(fontSize: 24),
                                        )
                                      : const Icon(Icons.label),
                                  title: Text(category.name),
                                );
                              },
                            ),
                          );
                        }
                        return Text(
                          l10n.onboardingNoCategoriesYet,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                    FilledButton.icon(
                      onPressed: _openCategoryCreation,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.createCategory),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: widget.onPrevious,
                          icon: const Icon(Icons.arrow_back),
                          label: Text(l10n.previous),
                        ),
                        FilledButton.icon(
                          onPressed: widget.onComplete,
                          icon: const Icon(Icons.check),
                          label: Text(l10n.onboardingFinish),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CategoryCreationModal extends StatefulWidget {
  const _CategoryCreationModal();

  @override
  State<_CategoryCreationModal> createState() => _CategoryCreationModalState();
}

class _CategoryCreationModalState extends State<_CategoryCreationModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _emojiController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emojiController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  Future<void> _createCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final emoji = _emojiController.text.trim();
    await context.read<CategoryCubit>().createCategory(
      name,
      emoji: emoji.isEmpty ? null : emoji,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.createCategory,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _emojiController,
                  decoration: InputDecoration(
                    labelText: l10n.emoji,
                    border: const OutlineInputBorder(),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.categoryName,
                    border: const OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _createCategory(),
                  autofocus: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _createCategory, child: Text(l10n.add)),
        ],
      ),
    );
  }
}
