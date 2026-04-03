import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_cubit.dart';
import 'features/categories/data/category_repository.dart';
import 'features/categories/presentation/category_cubit.dart';
import 'features/google_tasks/data/google_tasks_repository.dart';
import 'features/tasks/data/task_repository.dart';
import 'features/tasks/presentation/task_cubit.dart';
import 'features/widget_sync/widget_sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('it_IT');

  final authRepository = AuthRepository();
  final taskRepository = TaskRepository();
  final categoryRepository = CategoryRepository();
  final googleTasksRepository = GoogleTasksRepository();
  final widgetSyncService = WidgetSyncService();
  await widgetSyncService.initialize();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: taskRepository),
        RepositoryProvider.value(value: categoryRepository),
        RepositoryProvider.value(value: googleTasksRepository),
        RepositoryProvider.value(value: widgetSyncService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => TaskCubit(
              context.read<TaskRepository>(),
              context.read<WidgetSyncService>(),
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
