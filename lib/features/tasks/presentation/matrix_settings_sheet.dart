import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iketasks/core/locale/locale_cubit.dart';
import 'package:iketasks/core/notifications/notification_service.dart';
import 'package:iketasks/features/auth/presentation/auth_cubit.dart';
import 'package:iketasks/features/google_tasks/data/google_tasks_repository.dart';
import 'package:iketasks/features/google_tasks/presentation/google_tasks_import_page.dart';
import 'package:iketasks/features/widget/minimal_widget_sync_service.dart';
import 'package:iketasks/features/widget/widget_appearance_service.dart';
import 'package:iketasks/features/widget/unified_widget_settings_sheet.dart';
import 'package:iketasks/l10n/app_localizations.dart';
import 'completed_page.dart';
import 'matrix_enums.dart';
import 'matrix_support_widgets.dart';
import 'task_cubit.dart';

/// Shows the language picker bottom sheet.
Future<void> showLanguageSelector(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final currentLocale = context.read<LocaleCubit>().state.locale;

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.language, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              LanguageOption(languageName: l10n.languageEnglish, locale: const Locale('en'), currentLocale: currentLocale),
              LanguageOption(languageName: l10n.languageItalian, locale: const Locale('it'), currentLocale: currentLocale),
              LanguageOption(languageName: l10n.languageSpanish, locale: const Locale('es'), currentLocale: currentLocale),
              LanguageOption(languageName: l10n.languageFrench, locale: const Locale('fr'), currentLocale: currentLocale),
              LanguageOption(languageName: l10n.languageGerman, locale: const Locale('de'), currentLocale: currentLocale),
              LanguageOption(languageName: l10n.languageChinese, locale: const Locale('zh'), currentLocale: currentLocale),
              LanguageOption(languageName: l10n.languagePortuguese, locale: const Locale('pt'), currentLocale: currentLocale),
              LanguageOption(languageName: l10n.languageRussian, locale: const Locale('ru'), currentLocale: currentLocale),
              LanguageOption(languageName: l10n.languageJapanese, locale: const Locale('ja'), currentLocale: currentLocale),
              LanguageOption(languageName: l10n.languageArabic, locale: const Locale('ar'), currentLocale: currentLocale),
            ],
          ),
        ),
      );
    },
  );
}

/// Shows the about / support bottom sheet.
Future<void> showAboutSheet(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.about,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(l10n.appInfo, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(l10n.openSource, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => launchUrl(Uri.parse('https://github.com/thomasborgogno/iketasks')),
                icon: const Icon(Icons.code),
                label: Text(l10n.viewOnGitHub),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => launchUrl(Uri.parse('https://thomasborgogno.github.io/iketasks/privacy-policy')),
                icon: const Icon(Icons.privacy_tip_outlined),
                label: Text(l10n.privacyPolicy),
              ),
              const SizedBox(height: 24),
              Text(l10n.supportDevelopment, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(Uri.parse('https://paypal.me/thomasborgogno')),
                      icon: const Icon(Icons.paypal_outlined),
                      label: const Text('PayPal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(Uri.parse('https://ko-fi.com/thomasborgogno')),
                      icon: const Icon(Icons.local_cafe),
                      label: const Text('Ko-fi'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(l10n.reportIssue, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(l10n.reportIssueDescription, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  final uri = Uri(
                    scheme: 'mailto',
                    path: 'thomas.borgogno99@gmail.com',
                    query: 'subject=Eisenhower Matrix App - Issue Report',
                  );
                  await launchUrl(uri);
                },
                icon: const Icon(Icons.email_outlined),
                label: Text(l10n.reportIssue),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Shows the widget appearance bottom sheet.
Future<void> showWidgetAppearanceSheet(BuildContext context) async {
  final matrixService = context.read<WidgetAppearanceService>();
  final minimalService = context.read<MinimalWidgetSyncService>();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => UnifiedWidgetSettingsSheet(
      matrixService: matrixService,
      minimalService: minimalService,
    ),
  );
}

// ---------------------------------------------------------------------------
// MatrixSettingsSheet
// ---------------------------------------------------------------------------

class MatrixSettingsSheet extends StatefulWidget {
  const MatrixSettingsSheet({
    super.key,
    required this.user,
    required this.isAnonymous,
    required this.taskInputMode,
    required this.onTaskInputModeChanged,
  });

  final User user;
  final bool isAnonymous;
  final TaskInputMode taskInputMode;
  final ValueChanged<TaskInputMode> onTaskInputModeChanged;

  @override
  State<MatrixSettingsSheet> createState() => _MatrixSettingsSheetState();
}

class _MatrixSettingsSheetState extends State<MatrixSettingsSheet> {
  late TaskInputMode _taskInputMode;

  @override
  void initState() {
    super.initState();
    _taskInputMode = widget.taskInputMode;
  }

  String _taskInputModeLabel(AppLocalizations l10n, TaskInputMode mode) {
    switch (mode) {
      case TaskInputMode.quadrantOnly:
        return l10n.taskInputModeQuadrantOnly;
      case TaskInputMode.priorityOnly:
        return l10n.taskInputModePriorityOnly;
      case TaskInputMode.both:
        return l10n.taskInputModeBoth;
    }
  }

  Future<void> _onDeleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final authCubit = context.read<AuthCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(l10n.deleteAccount),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await authCubit.deleteAccount();
    if (authCubit.state.status == AuthStatus.error && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.deleteAccountError)),
      );
    }
  }

  Future<void> _openAccountActionsSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final sheetCtx = context;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (innerCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isAnonymous)
              ListTile(
                leading: const Icon(Icons.login),
                title: Text(l10n.upgradeToGoogle),
                onTap: () async {
                  Navigator.of(innerCtx).pop();
                  Navigator.of(sheetCtx).pop(); // close settings
                  try {
                    final result = await sheetCtx.read<AuthCubit>().upgradeToGoogle();
                    if (sheetCtx.mounted) {
                      final message = result == UpgradeResult.success
                          ? l10n.upgradeSuccess
                          : l10n.upgradeError;
                      ScaffoldMessenger.of(sheetCtx)
                          .showSnackBar(SnackBar(content: Text(message)));
                    }
                  } catch (_) {}
                },
              ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.signOut),
              onTap: () async {
                Navigator.of(innerCtx).pop();
                Navigator.of(sheetCtx).pop();
                await sheetCtx.read<AuthCubit>().signOut();
              },
            ),
            if (!widget.isAnonymous)
              ListTile(
                leading: Icon(Icons.delete_forever, color: Theme.of(innerCtx).colorScheme.error),
                title: Text(
                  l10n.deleteAccount,
                  style: TextStyle(color: Theme.of(innerCtx).colorScheme.error),
                ),
                onTap: () {
                  Navigator.of(innerCtx).pop();
                  Navigator.of(sheetCtx).pop();
                  _onDeleteAccount();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notificationService = context.read<NotificationService>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: StatefulBuilder(
          builder: (_, setInnerState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.settings, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              ProfileHeader(
                user: widget.user,
                onLogout: _openAccountActionsSheet,
              ),
              const SizedBox(height: 10),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(l10n.completedTasks),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CompletedPage(uid: widget.user.uid),
                    ),
                  );
                },
              ),
              if (!widget.isAnonymous)
                ListTile(
                  leading: const Icon(Icons.cloud_download_outlined),
                  title: Text(l10n.importFromGoogleTasks),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (pageContext) => RepositoryProvider.value(
                          value: pageContext.read<GoogleTasksRepository>(),
                          child: const GoogleTasksImportPage(),
                        ),
                      ),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.widgets_outlined),
                title: Text(l10n.widgetAppearance),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pop();
                  showWidgetAppearanceSheet(context);
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: Text(l10n.persistentNotification),
                subtitle: Text(l10n.persistentNotificationDescription),
                value: notificationService.isEnabled,
                onChanged: (value) async {
                  final tasks = context.read<TaskCubit>().state.tasks;
                  await notificationService.setEnabled(value, tasks);
                  setInnerState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.tune_outlined),
                title: Text(l10n.taskInputMode),
                trailing: DropdownButton<TaskInputMode>(
                  value: _taskInputMode,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _taskInputMode = value);
                    widget.onTaskInputModeChanged(value);
                  },
                  items: TaskInputMode.values
                      .map(
                        (mode) => DropdownMenuItem<TaskInputMode>(
                          value: mode,
                          child: Text(_taskInputModeLabel(l10n, mode)),
                        ),
                      )
                      .toList(),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(l10n.language),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pop();
                  showLanguageSelector(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.about),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pop();
                  showAboutSheet(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
