import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iketasks/l10n/app_localizations.dart';
import 'package:iketasks/features/auth/presentation/auth_cubit.dart';

class OnboardingSignInPage extends StatefulWidget {
  const OnboardingSignInPage({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  State<OnboardingSignInPage> createState() => _OnboardingSignInPageState();
}

class _OnboardingSignInPageState extends State<OnboardingSignInPage>
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
      child: LayoutBuilder(
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
                        Icons.login,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                      Column(
                        children: [
                          Text(
                            l10n.onboardingSignInTitle,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.onboardingSignInDescription,
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      TextButton(
                        onPressed: () => launchUrl(
                          Uri.parse(
                            'https://thomasborgogno.github.io/iketasks/privacy-policy',
                          ),
                        ),
                        child: Text(
                          l10n.privacyPolicy,
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: widget.onPrevious,
                        icon: const Icon(Icons.arrow_back),
                        label: Text(l10n.previous),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
