import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/locale/locale_cubit.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_cubit.dart';
import 'features/auth/presentation/sign_in_page.dart';
import 'features/categories/presentation/category_cubit.dart';
import 'features/tasks/presentation/matrix_page.dart';
import 'features/tasks/presentation/task_cubit.dart';
import 'package:eisenhower_matrix_app/l10n/app_localizations.dart';

class EisenhowerApp extends StatelessWidget {
  const EisenhowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return MaterialApp(
          title: 'Eisenhower Matrix',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.system,
          locale: localeState.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('it'), // Italian
            Locale('es'), // Spanish
            Locale('fr'), // French
            Locale('de'), // German
            Locale('zh'), // Chinese
            Locale('pt'), // Portuguese
            Locale('ru'), // Russian
            Locale('ja'), // Japanese
            Locale('ar'), // Arabic
          ],
          builder: (context, child) {
            // Update notification service localizations when locale changes
            final l10n = AppLocalizations.of(context);
            if (l10n != null) {
              context.read<NotificationService>().setLocalizations(l10n);
            }
            return child ?? const SizedBox.shrink();
          },
          home: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              final user = state.user;
              if (user != null) {
                context.read<TaskCubit>().bindUser(user.uid);
                context.read<CategoryCubit>().bindUser(user.uid);
              }
            },
            builder: (context, state) {
              if (state.status == AuthStatus.loading ||
                  state.status == AuthStatus.unknown) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.status == AuthStatus.error) {
                return Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        state.errorMessage ??
                            AppLocalizations.of(context)!.authError,
                      ),
                    ),
                  ),
                );
              }

              if (state.status == AuthStatus.authenticated) {
                return const MatrixPage();
              }

              return const SignInPage();
            },
          ),
        );
      },
    );
  }
}
