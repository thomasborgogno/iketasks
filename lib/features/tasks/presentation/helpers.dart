import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum EisenhowerQuadrant {
  importantUrgent,
  importantNotUrgent,
  notImportantUrgent,
  notImportantNotUrgent,
}

Color quadrantColor(EisenhowerQuadrant q) {
  switch (q) {
    case EisenhowerQuadrant.importantUrgent:
      return const Color(0xFFD7263D);
    case EisenhowerQuadrant.importantNotUrgent:
      return const Color(0xFF1B998B);
    case EisenhowerQuadrant.notImportantUrgent:
      return const Color(0xFFF4A261);
    case EisenhowerQuadrant.notImportantNotUrgent:
      return const Color(0xFF457B9D);
  }
}

extension EisenhowerQuadrantX on EisenhowerQuadrant {
  String description(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case EisenhowerQuadrant.importantUrgent:
        return l10n.quadrantImportantUrgent;
      case EisenhowerQuadrant.importantNotUrgent:
        return l10n.quadrantImportantNotUrgent;
      case EisenhowerQuadrant.notImportantUrgent:
        return l10n.quadrantNotImportantUrgent;
      case EisenhowerQuadrant.notImportantNotUrgent:
        return l10n.quadrantNotImportantNotUrgent;
    }
  }

  String name(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case EisenhowerQuadrant.importantUrgent:
        return l10n.quadrantNamePriority;
      case EisenhowerQuadrant.importantNotUrgent:
        return l10n.quadrantNamePlan;
      case EisenhowerQuadrant.notImportantUrgent:
        return l10n.quadrantNameDelegate;
      case EisenhowerQuadrant.notImportantNotUrgent:
        return l10n.quadrantNameEliminate;
    }
  }

  String fullName(BuildContext context) {
    return '${name(context)} (${description(context)})';
  }

  String importLabel(BuildContext context) {
    return '${name(context)}\n${description(context)}';
  }

  String get value {
    switch (this) {
      case EisenhowerQuadrant.importantUrgent:
        return 'q1';
      case EisenhowerQuadrant.importantNotUrgent:
        return 'q2';
      case EisenhowerQuadrant.notImportantUrgent:
        return 'q3';
      case EisenhowerQuadrant.notImportantNotUrgent:
        return 'q4';
    }
  }

  static EisenhowerQuadrant fromValue(String value) {
    switch (value) {
      case 'q1':
        return EisenhowerQuadrant.importantUrgent;
      case 'q2':
        return EisenhowerQuadrant.importantNotUrgent;
      case 'q3':
        return EisenhowerQuadrant.notImportantUrgent;
      default:
        return EisenhowerQuadrant.notImportantNotUrgent;
    }
  }
}
