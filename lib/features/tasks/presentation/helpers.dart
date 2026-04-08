import 'dart:ui';

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
  String get description {
    switch (this) {
      case EisenhowerQuadrant.importantUrgent:
        return 'Importante, urgente';
      case EisenhowerQuadrant.importantNotUrgent:
        return 'Importante, non urgente';
      case EisenhowerQuadrant.notImportantUrgent:
        return 'Non importante, urgente';
      case EisenhowerQuadrant.notImportantNotUrgent:
        return 'Non importante, non urgente';
    }
  }

  String get name {
    switch (this) {
      case EisenhowerQuadrant.importantUrgent:
        return 'Priorità';
      case EisenhowerQuadrant.importantNotUrgent:
        return 'Pianifica';
      case EisenhowerQuadrant.notImportantUrgent:
        return 'Delega';
      case EisenhowerQuadrant.notImportantNotUrgent:
        return 'Elimina';
    }
  }

  String get fullName {
    switch (this) {
      case EisenhowerQuadrant.importantUrgent:
        return '$name ($description)';
      case EisenhowerQuadrant.importantNotUrgent:
        return '$name ($description)';
      case EisenhowerQuadrant.notImportantUrgent:
        return '$name ($description)';
      case EisenhowerQuadrant.notImportantNotUrgent:
        return '$name ($description)';
    }
  }

  String get importLabel {
    switch (this) {
      case EisenhowerQuadrant.importantUrgent:
        return '$name\n$description';
      case EisenhowerQuadrant.importantNotUrgent:
        return '$name\n$description';
      case EisenhowerQuadrant.notImportantUrgent:
        return '$name\n$description';
      case EisenhowerQuadrant.notImportantNotUrgent:
        return '$name\n$description';
    }
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
