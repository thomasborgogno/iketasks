import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_cubit.dart';
import 'features/auth/presentation/sign_in_page.dart';
import 'features/categories/presentation/category_cubit.dart';
import 'features/tasks/presentation/matrix_page.dart';
import 'features/tasks/presentation/task_cubit.dart';

class EisenhowerApp extends StatelessWidget {
  const EisenhowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eisenhower Matrix',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
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
                  child: Text(state.errorMessage ?? 'Errore autenticazione'),
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
  }
}
