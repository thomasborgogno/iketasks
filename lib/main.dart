import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/locale/locale_cubit.dart';
import 'core/notifications/notification_service.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_cubit.dart';
import 'features/categories/data/category_repository.dart';
import 'features/categories/presentation/category_cubit.dart';
import 'features/google_tasks/data/google_tasks_repository.dart';
import 'features/onboarding/data/onboarding_repository.dart';
import 'features/onboarding/presentation/onboarding_cubit.dart';
import 'features/tasks/data/task_repository.dart';
import 'features/tasks/presentation/task_cubit.dart';
import 'features/widget/widget_appearance_service.dart';
import 'features/widget/widget_sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize date formatting for all supported locales
  await initializeDateFormatting('en_US');
  await initializeDateFormatting('it_IT');
  await initializeDateFormatting('es_ES');
  await initializeDateFormatting('fr_FR');
  await initializeDateFormatting('de_DE');
  await initializeDateFormatting('zh_CN');
  await initializeDateFormatting('pt_PT');
  await initializeDateFormatting('ru_RU');
  await initializeDateFormatting('ja_JP');
  await initializeDateFormatting('ar_SA');

  final authRepository = AuthRepository();
  final taskRepository = TaskRepository();
  final categoryRepository = CategoryRepository();
  final googleTasksRepository = GoogleTasksRepository();
  final onboardingRepository = OnboardingRepository();
  final widgetSyncService = WidgetSyncService();
  await widgetSyncService.initialize();
  final widgetAppearanceService = WidgetAppearanceService();
  await widgetAppearanceService.initialize();
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize locale cubit
  final localeCubit = LocaleCubit();
  await localeCubit.loadSavedLocale();

  // Initialize onboarding cubit
  final onboardingCubit = OnboardingCubit(onboardingRepository);
  await onboardingCubit.checkOnboardingStatus();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: taskRepository),
        RepositoryProvider.value(value: categoryRepository),
        RepositoryProvider.value(value: googleTasksRepository),
        RepositoryProvider.value(value: onboardingRepository),
        RepositoryProvider.value(value: widgetSyncService),
        RepositoryProvider.value(value: widgetAppearanceService),
        RepositoryProvider.value(value: notificationService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: localeCubit),
          BlocProvider.value(value: onboardingCubit),
          BlocProvider(
            create: (context) => AuthCubit(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => TaskCubit(
              context.read<TaskRepository>(),
              context.read<WidgetSyncService>(),
              context.read<NotificationService>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                CategoryCubit(context.read<CategoryRepository>()),
          ),
        ],
        child: const EisenhowerApp(),
      ),
    ),
  );
}
