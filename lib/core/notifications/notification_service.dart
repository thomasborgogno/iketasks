import 'dart:async';

import 'package:iketasks/l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/tasks/domain/task_item.dart';
import '../../features/tasks/presentation/helpers.dart';

class NotificationService {
  static const int _notificationId = 42;
  static const String _channelId = 'priority_tasks';
  static const String _prefKey = 'notification_enabled';
  static const String _actionNewTask = 'new_task';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _enabled = true;
  int tasksToShow = 6;
  List<TaskItem> _lastTasks = [];
  Timer? _watchdog;
  AppLocalizations? _l10n;

  final StreamController<void> _newTaskController =
      StreamController<void>.broadcast();

  Stream<void> get onNewTaskRequested => _newTaskController.stream;

  bool get isEnabled => _enabled;

  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_prefKey) ?? false;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // Create notification channel with localized strings if available
    final channel = AndroidNotificationChannel(
      _channelId,
      _l10n?.notificationChannelName ?? 'Priority tasks',
      description:
          _l10n?.notificationChannelDescription ??
          'Show priority tasks from IkeTasks',
      importance: Importance.low,
    );
    await androidImpl?.createNotificationChannel(channel);
    _startWatchdog();
  }

  void _startWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer.periodic(const Duration(minutes: 1), (_) async {
      if (!_enabled || _lastTasks.isEmpty) return;
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final active = await androidImpl?.getActiveNotifications() ?? [];
      final isShowing = active.any((n) => n.id == _notificationId);
      if (!isShowing) {
        await updatePriorityNotification(_lastTasks);
      }
    });
  }

  void _onNotificationResponse(NotificationResponse response) {
    if (response.actionId == _actionNewTask) {
      _newTaskController.add(null);
    }
  }

  void dispose() {
    _watchdog?.cancel();
    _newTaskController.close();
  }

  Future<void> setEnabled(bool value, List<TaskItem> currentTasks) async {
    if (value) {
      // Request permission when enabling notifications
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await androidImpl?.requestNotificationsPermission();
      if (granted != true) {
        return; // Permission denied, don't enable notifications
      }
    }

    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
    if (!value) {
      _lastTasks = [];
      await _plugin.cancel(id: _notificationId);
    } else {
      await updatePriorityNotification(currentTasks);
    }
  }

  Future<void> updatePriorityNotification(List<TaskItem> allTasks) async {
    if (!_enabled) return;
    _lastTasks = List.unmodifiable(allTasks);

    final incomplete = allTasks.where((t) => !t.completed).toList();

    final q1 = incomplete
        .where((t) => t.quadrant == EisenhowerQuadrant.importantUrgent)
        .toList();

    final top = List<TaskItem>.from(q1.take(tasksToShow));

    // if (top.length < tasksToShow) {
    //   final q2 = incomplete
    //       .where((t) => t.quadrant == EisenhowerQuadrant.importantNotUrgent)
    //       .take(tasksToShow - top.length);
    //   top.addAll(q2);
    // }

    if (top.isEmpty) {
      await _plugin.cancel(id: _notificationId);
      return;
    }

    final lines = top.map((t) => t.title).toList();

    final title = lines.first;

    lines.removeAt(0);

    final styleInformation = InboxStyleInformation(
      lines,
      summaryText: _l10n?.taskCount(top.length) ?? '${top.length} tasks',
    );

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _l10n?.notificationChannelName ?? 'Priority tasks',
      channelDescription:
          _l10n?.notificationChannelDescription ??
          'Show priority tasks from IkeTasks',
      importance: Importance.low,
      priority: Priority.low,
      visibility: NotificationVisibility.secret,
      ongoing: true,
      autoCancel: false,
      styleInformation: styleInformation,
      actions: [
        AndroidNotificationAction(
          _actionNewTask,
          _l10n?.createNewTask ?? 'Create new task',
          showsUserInterface: true,
        ),
      ],
    );

    await _plugin.show(
      id: _notificationId,
      title: title,
      body: lines.first,
      notificationDetails: NotificationDetails(android: androidDetails),
    );
  }
}
