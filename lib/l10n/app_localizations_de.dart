// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get authError => 'Authentifizierungsfehler';

  @override
  String get signInSubtitle =>
      'Organisieren Sie Ihre Aufgaben nach Dringlichkeit und Wichtigkeit.';

  @override
  String get signInWithGoogle => 'Mit Google anmelden';

  @override
  String get googleUser => 'Google-Benutzer';

  @override
  String get settings => 'Einstellungen';

  @override
  String get profileAndSettings => 'Profil und Einstellungen';

  @override
  String get signOut => 'Abmelden';

  @override
  String get quadrantImportantUrgent => 'Wichtig, dringend';

  @override
  String get quadrantImportantNotUrgent => 'Wichtig, nicht dringend';

  @override
  String get quadrantNotImportantUrgent => 'Nicht wichtig, dringend';

  @override
  String get quadrantNotImportantNotUrgent => 'Nicht wichtig, nicht dringend';

  @override
  String get quadrantNamePriority => 'Priorität';

  @override
  String get quadrantNamePlan => 'Planen';

  @override
  String get quadrantNameDelegate => 'Delegieren';

  @override
  String get quadrantNameEliminate => 'Eliminieren';

  @override
  String get yourEisenhowerMatrix => 'Ihre Eisenhower-Matrix';

  @override
  String greeting(String name) {
    return 'Hallo, $name!';
  }

  @override
  String get columnView => 'Spaltenansicht';

  @override
  String get gridView => 'Rasteransicht';

  @override
  String get empty => 'Leer';

  @override
  String get newTask => 'Neue Aufgabe';

  @override
  String get editTask => 'Aufgabe bearbeiten';

  @override
  String get taskTitle => 'Titel';

  @override
  String get taskDescription => 'Beschreibung';

  @override
  String get priority => 'Priorität';

  @override
  String get important => 'Wichtig';

  @override
  String get urgent => 'Dringend';

  @override
  String get quadrant => 'Quadrant';

  @override
  String get category => 'Kategorie';

  @override
  String get createCategory => 'Kategorie erstellen';

  @override
  String get dueDate => 'Fälligkeitsdatum';

  @override
  String get removeDescription => 'Beschreibung entfernen';

  @override
  String get removeDescriptionConfirm =>
      'Möchten Sie die Beschreibung entfernen?';

  @override
  String get removeDueDate => 'Fälligkeitsdatum entfernen';

  @override
  String get removeDueDateConfirm =>
      'Möchten Sie das Fälligkeitsdatum entfernen?';

  @override
  String get deleteTask => 'Aufgabe löschen';

  @override
  String get deleteTaskConfirm => 'Möchten Sie diese Aufgabe löschen?';

  @override
  String get save => 'Speichern';

  @override
  String get createTask => 'Aufgabe erstellen';

  @override
  String get delete => 'Löschen';

  @override
  String get remove => 'Entfernen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String dueDateLabel(String date) {
    return 'Fällig: $date';
  }

  @override
  String get completedTasks => 'Erledigte Aufgaben';

  @override
  String get loadingError => 'Ladefehler';

  @override
  String get noCompletedTasks => 'Keine erledigten Aufgaben';

  @override
  String completedOn(String date) {
    return 'Erledigt am $date';
  }

  @override
  String get categories => 'Kategorien';

  @override
  String get categoryManagement => 'Kategorienverwaltung';

  @override
  String get emoji => 'Emoji';

  @override
  String get categoryName => 'Kategoriename';

  @override
  String get add => 'Hinzufügen';

  @override
  String get close => 'Schließen';

  @override
  String get deleteCategory => 'Kategorie löschen';

  @override
  String deleteCategoryConfirm(String name) {
    return '\"$name\" löschen?';
  }

  @override
  String get deleteCategoryWarning =>
      'Zugehörige Aufgaben verlieren ihre Kategorie.';

  @override
  String get importFromGoogleTasks => 'Von Google Tasks importieren';

  @override
  String get loadingGoogleTasks => 'Google Tasks werden geladen...';

  @override
  String get unknownError => 'Unbekannter Fehler';

  @override
  String get retry => 'Wiederholen';

  @override
  String get noGoogleTasksFound => 'Keine Aufgaben in Google Tasks gefunden.';

  @override
  String continueWithSelected(int count) {
    return 'Weiter ($count)';
  }

  @override
  String get selectAll => 'Alle auswählen';

  @override
  String get deselectAll => 'Alle abwählen';

  @override
  String assignQuadrant(int assigned, int total) {
    return 'Quadrant zuweisen ($assigned/$total)';
  }

  @override
  String get quadrantAssigned =>
      'Quadrant zugewiesen ✓ — tippen Sie auf einen anderen, um ihn zu ändern';

  @override
  String get dragOrTapQuadrant => 'Ziehen oder tippen Sie auf einen Quadranten';

  @override
  String get previous => 'Zurück';

  @override
  String get skip => 'Überspringen';

  @override
  String get importTasks => 'Aufgaben importieren';

  @override
  String get widgetAppearance => 'Widget-Aussehen';

  @override
  String get theme => 'Thema';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Hell';

  @override
  String get darkTheme => 'Dunkel';

  @override
  String get background => 'Hintergrund';

  @override
  String transparency(int percent) {
    return 'Transparenz: $percent%';
  }

  @override
  String get textSize => 'Textgröße';

  @override
  String get small => 'Klein';

  @override
  String get medium => 'Mittel';

  @override
  String get large => 'Groß';

  @override
  String get textColor => 'Textfarbe';

  @override
  String get white => 'Weiß';

  @override
  String get black => 'Schwarz';

  @override
  String get quadrants => 'Quadranten';

  @override
  String get widgetUpdated => 'Widget aktualisiert.';

  @override
  String get colorRed => 'Rot';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorYellow => 'Gelb';

  @override
  String get colorGreen => 'Grün';

  @override
  String get colorBlue => 'Blau';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorPurple => 'Lila';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorBrown => 'Braun';

  @override
  String get colorGray => 'Grau';

  @override
  String get colorTeal => 'Blaugrün';

  @override
  String get colorCyan => 'Cyan';

  @override
  String get colorLime => 'Limette';

  @override
  String get colorAmber => 'Bernstein';

  @override
  String get colorDeepOrange => 'Dunkles Orange';

  @override
  String get notificationChannelName => 'Prioritätsaufgaben';

  @override
  String get notificationChannelDescription =>
      'Prioritätsaufgaben aus der Eisenhower-Matrix anzeigen';

  @override
  String get createNewTask => 'Neue Aufgabe erstellen';

  @override
  String taskCount(int count) {
    return '$count Aufgaben';
  }

  @override
  String get persistentNotification => 'Dauerhafte Benachrichtigung';

  @override
  String get persistentNotificationDescription =>
      'Prioritätsaufgaben in der Benachrichtigungsleiste anzeigen';

  @override
  String get language => 'Sprache';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageItalian => 'Italienisch';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String get languageFrench => 'Französisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageChinese => 'Chinesisch';

  @override
  String get languagePortuguese => 'Portugiesisch';

  @override
  String get languageRussian => 'Russisch';

  @override
  String get languageJapanese => 'Japanisch';

  @override
  String get languageArabic => 'Arabisch';

  @override
  String get onboardingWelcomeTitle => 'Willkommen zur Eisenhower-Matrix';

  @override
  String get onboardingWelcomeSubtitle =>
      'Das ultimative Tool zur Priorisierung Ihrer Aufgaben';

  @override
  String get onboardingWelcomeDescription =>
      'Die Eisenhower-Matrix hilft Ihnen, Aufgaben nach Dringlichkeit und Wichtigkeit zu organisieren, damit Sie sich auf das konzentrieren können, was wirklich zählt.';

  @override
  String get onboardingGetStarted => 'Loslegen';

  @override
  String get onboardingNotUrgent => 'Nicht Dringend';

  @override
  String get onboardingNotImportant => 'Nicht Wichtig';

  @override
  String get onboardingQ1Description => 'Jetzt tun';

  @override
  String get onboardingQ2Description => 'Planen';

  @override
  String get onboardingQ3Description => 'Delegieren';

  @override
  String get onboardingQ4Description => 'Eliminieren';

  @override
  String get onboardingFeaturesTitle => 'Leistungsstarke Funktionen';

  @override
  String get onboardingFeatureCategories => 'Mit Kategorien Organisieren';

  @override
  String get onboardingFeatureCategoriesDesc =>
      'Erstellen Sie benutzerdefinierte Kategorien, um Ihre Aufgaben nach Projekt oder Kontext zu gruppieren';

  @override
  String get onboardingFeatureNotifications => 'Dauerbenachrichtigung';

  @override
  String get onboardingFeatureNotificationsDesc =>
      'Prüfen Sie Ihre prioritären Aufgaben in der Benachrichtigungsleiste';

  @override
  String get onboardingFeatureWidget => 'Startbildschirm-Widget';

  @override
  String get onboardingFeatureWidgetDesc =>
      'Sehen Sie Ihre wichtigen Aufgaben auf einen Blick, ohne die App zu öffnen';

  @override
  String get onboardingFeatureSync => 'Cloud-Synchronisation';

  @override
  String get onboardingFeatureSyncDesc =>
      'Ihre Aufgaben werden automatisch auf allen Ihren Geräten synchronisiert';

  @override
  String get onboardingContinue => 'Weiter';

  @override
  String get onboardingSignInTitle => 'Anmelden, um Fortzufahren';

  @override
  String get onboardingSignInDescription =>
      'Melden Sie sich mit Ihrem Google-Konto an, um Ihre Aufgaben zu synchronisieren und von überall darauf zuzugreifen';

  @override
  String get onboardingSignInSuccess => 'Erfolgreich angemeldet!';

  @override
  String get onboardingCategoriesTitle => 'Erstellen Sie Ihre Kategorien';

  @override
  String get onboardingCategoriesDescription =>
      'Kategorien helfen Ihnen, Aufgaben nach Projekt, Kontext oder beliebig zu organisieren';

  @override
  String get onboardingNoCategoriesYet =>
      'Noch keine Kategorien. Erstellen Sie Ihre erste!';

  @override
  String get onboardingFinish => 'Fertig';
}
