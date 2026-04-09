import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eisenhower_matrix_app/l10n/app_localizations.dart';
import 'package:eisenhower_matrix_app/features/auth/presentation/auth_cubit.dart';
import 'package:eisenhower_matrix_app/features/categories/presentation/category_cubit.dart';
import 'onboarding_cubit.dart';

/// Main onboarding wizard that guides users through initial setup
class OnboardingWizard extends StatefulWidget {
  const OnboardingWizard({super.key});

  @override
  State<OnboardingWizard> createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends State<OnboardingWizard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    context.read<OnboardingCubit>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _WelcomePage(onNext: _nextPage),
                  _FeaturesPage(onNext: _nextPage, onPrevious: _previousPage),
                  _SignInPage(onNext: _nextPage, onPrevious: _previousPage),
                  _CategorySetupPage(
                    onComplete: _skipOnboarding,
                    onPrevious: _previousPage,
                  ),
                ],
              ),
            ),
            _PageIndicator(currentPage: _currentPage, totalPages: 4),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Welcome page explaining the Eisenhower Matrix
class _WelcomePage extends StatefulWidget {
  const _WelcomePage({required this.onNext});

  final VoidCallback onNext;

  @override
  State<_WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<_WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  Icon(
                    Icons.grid_4x4,
                    size: 100,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.onboardingWelcomeTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.onboardingWelcomeSubtitle,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _EisenhowerMatrixDiagram(),
                  const SizedBox(height: 32),
                  Text(
                    l10n.onboardingWelcomeDescription,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  FilledButton.icon(
                    onPressed: widget.onNext,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(l10n.onboardingGetStarted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated Eisenhower Matrix diagram
class _EisenhowerMatrixDiagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 60),
              Expanded(
                child: Center(
                  child: Text(
                    l10n.urgent,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    l10n.onboardingNotUrgent,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                RotatedBox(
                  quarterTurns: 3,
                  child: Center(
                    child: Text(
                      l10n.important,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _QuadrantBox(
                    color: Colors.red.shade100,
                    title: l10n.quadrantNamePriority,
                    subtitle: l10n.onboardingQ1Description,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuadrantBox(
                    color: Colors.green.shade100,
                    title: l10n.quadrantNamePlan,
                    subtitle: l10n.onboardingQ2Description,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                RotatedBox(
                  quarterTurns: 3,
                  child: Center(
                    child: Text(
                      l10n.onboardingNotImportant,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _QuadrantBox(
                    color: Colors.orange.shade100,
                    title: l10n.quadrantNameDelegate,
                    subtitle: l10n.onboardingQ3Description,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuadrantBox(
                    color: Colors.grey.shade300,
                    title: l10n.quadrantNameEliminate,
                    subtitle: l10n.onboardingQ4Description,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuadrantBox extends StatelessWidget {
  const _QuadrantBox({
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Features showcase page
class _FeaturesPage extends StatefulWidget {
  const _FeaturesPage({required this.onNext, required this.onPrevious});

  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  State<_FeaturesPage> createState() => _FeaturesPageState();
}

class _FeaturesPageState extends State<_FeaturesPage>
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Icon(Icons.star, size: 80, color: theme.colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  l10n.onboardingFeaturesTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _FeatureItem(
                  icon: Icons.category,
                  title: l10n.onboardingFeatureCategories,
                  description: l10n.onboardingFeatureCategoriesDesc,
                ),
                const SizedBox(height: 20),
                _FeatureItem(
                  icon: Icons.notifications,
                  title: l10n.onboardingFeatureNotifications,
                  description: l10n.onboardingFeatureNotificationsDesc,
                ),
                const SizedBox(height: 20),
                _FeatureItem(
                  icon: Icons.widgets,
                  title: l10n.onboardingFeatureWidget,
                  description: l10n.onboardingFeatureWidgetDesc,
                ),
                const SizedBox(height: 20),
                _FeatureItem(
                  icon: Icons.cloud_sync,
                  title: l10n.onboardingFeatureSync,
                  description: l10n.onboardingFeatureSyncDesc,
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: widget.onPrevious,
                      icon: const Icon(Icons.arrow_back),
                      label: Text(l10n.previous),
                    ),
                    FilledButton.icon(
                      onPressed: widget.onNext,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(l10n.onboardingContinue),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.onPrimaryContainer,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(description, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sign-in page within onboarding
class _SignInPage extends StatefulWidget {
  const _SignInPage({required this.onNext, required this.onPrevious});

  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  State<_SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<_SignInPage>
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          widget.onNext();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Icon(Icons.login, size: 80, color: theme.colorScheme.primary),
                  const SizedBox(height: 24),
                  Text(
                    l10n.onboardingSignInTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.onboardingSignInDescription,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state.status == AuthStatus.loading;
                      if (state.status == AuthStatus.authenticated) {
                        return Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 64,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.onboardingSignInSuccess,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: widget.onNext,
                              icon: const Icon(Icons.arrow_forward),
                              label: Text(l10n.onboardingContinue),
                            ),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          FilledButton.icon(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context
                                        .read<AuthCubit>()
                                        .signInWithGoogle();
                                  },
                            icon: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Image.asset(
                                    'assets/google_logo.png',
                                    height: 24,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.g_mobiledata),
                                  ),
                            label: Text(l10n.signInWithGoogle),
                          ),
                          if (state.status == AuthStatus.error) ...[
                            const SizedBox(height: 16),
                            Text(
                              state.errorMessage ?? l10n.authError,
                              style: TextStyle(color: theme.colorScheme.error),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  TextButton.icon(
                    onPressed: widget.onPrevious,
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.previous),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category setup page with modal interface
class _CategorySetupPage extends StatefulWidget {
  const _CategorySetupPage({
    required this.onComplete,
    required this.onPrevious,
  });

  final VoidCallback onComplete;
  final VoidCallback onPrevious;

  @override
  State<_CategorySetupPage> createState() => _CategorySetupPageState();
}

class _CategorySetupPageState extends State<_CategorySetupPage>
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

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Icon(
                  Icons.category,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.onboardingCategoriesTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.onboardingCategoriesDescription,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
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
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _openCategoryCreation,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.createCategory),
                ),
                const SizedBox(height: 48),
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
        ],
      ),
    );
  }
}

/// Modal bottom sheet for category creation
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

/// Page indicator dots
class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.currentPage, required this.totalPages});

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentPage
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }
}
