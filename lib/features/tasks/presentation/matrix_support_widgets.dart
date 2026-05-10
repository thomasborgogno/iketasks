import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iketasks/core/locale/locale_cubit.dart';
import 'package:iketasks/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Profile widgets
// ---------------------------------------------------------------------------

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user, this.onLogout});

  final User user;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final isAnonymous = user.isAnonymous;
    final name = isAnonymous ? null : user.displayName?.trim();
    final email = isAnonymous ? null : user.email?.trim();
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
    ProfileAvatar(photoUrl: isAnonymous ? null : user.photoURL, radius: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAnonymous
                    ? l10n.guestUser
                    : (name == null || name.isEmpty)
                        ? l10n.googleUser
                        : name,
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
            icon: const Icon(Icons.manage_accounts_outlined),
            tooltip: l10n.profileAndSettings,
          ),
      ],
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.photoUrl, this.radius = 18});

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
// Language option widget
// ---------------------------------------------------------------------------

class LanguageOption extends StatelessWidget {
  const LanguageOption({
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
