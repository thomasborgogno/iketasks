// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get authError => 'Errore autenticazione';

  @override
  String get signInSubtitle =>
      'Organizza le tue attivita per urgenza e importanza.';

  @override
  String get signInWithGoogle => 'Accedi con Google';

  @override
  String get googleUser => 'Utente Google';

  @override
  String get settings => 'Impostazioni';

  @override
  String get profileAndSettings => 'Profilo e impostazioni';

  @override
  String get signOut => 'Esci';

  @override
  String get quadrantImportantUrgent => 'Importante, urgente';

  @override
  String get quadrantImportantNotUrgent => 'Importante, non urgente';

  @override
  String get quadrantNotImportantUrgent => 'Non importante, urgente';

  @override
  String get quadrantNotImportantNotUrgent => 'Non importante, non urgente';

  @override
  String get quadrantNamePriority => 'Priorità';

  @override
  String get quadrantNamePlan => 'Pianifica';

  @override
  String get quadrantNameDelegate => 'Delega';

  @override
  String get quadrantNameEliminate => 'Elimina';

  @override
  String get yourEisenhowerMatrix => 'La tua matrice di Eisenhower';

  @override
  String greeting(String name) {
    return 'Ciao, $name!';
  }

  @override
  String get columnView => 'Vista a colonne';

  @override
  String get gridView => 'Vista a griglia';

  @override
  String get empty => 'Vuoto';

  @override
  String get newTask => 'Nuova attività';

  @override
  String get editTask => 'Modifica attività';

  @override
  String get taskTitle => 'Titolo';

  @override
  String get taskDescription => 'Descrizione';

  @override
  String get priority => 'Priorità';

  @override
  String get important => 'Importante';

  @override
  String get urgent => 'Urgente';

  @override
  String get quadrant => 'Quadrante';

  @override
  String get category => 'Categoria';

  @override
  String get createCategory => 'Crea una categoria';

  @override
  String get dueDate => 'Scadenza';

  @override
  String get removeDescription => 'Rimuovi descrizione';

  @override
  String get removeDescriptionConfirm => 'Vuoi rimuovere la descrizione?';

  @override
  String get removeDueDate => 'Rimuovi scadenza';

  @override
  String get removeDueDateConfirm => 'Vuoi rimuovere la scadenza?';

  @override
  String get deleteTask => 'Elimina attività';

  @override
  String get deleteTaskConfirm => 'Vuoi eliminare questa attività?';

  @override
  String get save => 'Salva';

  @override
  String get createTask => 'Crea attività';

  @override
  String get delete => 'Elimina';

  @override
  String get remove => 'Rimuovi';

  @override
  String get cancel => 'Annulla';

  @override
  String dueDateLabel(String date) {
    return 'Scadenza: $date';
  }

  @override
  String get completedTasks => 'Attività completate';

  @override
  String get loadingError => 'Errore nel caricamento';

  @override
  String get noCompletedTasks => 'Nessuna attività completata';

  @override
  String completedOn(String date) {
    return 'Completata il $date';
  }

  @override
  String get categories => 'Categorie';

  @override
  String get categoryManagement => 'Gestione categorie';

  @override
  String get emoji => 'Emoji';

  @override
  String get categoryName => 'Nome categoria';

  @override
  String get add => 'Aggiungi';

  @override
  String get close => 'Chiudi';

  @override
  String get deleteCategory => 'Elimina categoria';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Eliminare \"$name\"?';
  }

  @override
  String get deleteCategoryWarning =>
      'Le attività associate perderanno la categoria.';

  @override
  String get importFromGoogleTasks => 'Importa da Google Tasks';

  @override
  String get loadingGoogleTasks => 'Caricamento attività Google...';

  @override
  String get unknownError => 'Errore sconosciuto';

  @override
  String get retry => 'Riprova';

  @override
  String get noGoogleTasksFound => 'Nessuna attività trovata su Google Tasks.';

  @override
  String continueWithSelected(int count) {
    return 'Continua ($count)';
  }

  @override
  String get selectAll => 'Seleziona tutto';

  @override
  String get deselectAll => 'Deseleziona tutto';

  @override
  String assignQuadrant(int assigned, int total) {
    return 'Assegna quadrante ($assigned/$total)';
  }

  @override
  String get quadrantAssigned =>
      'Quadrante assegnato ✓ — tocca un altro per cambiarlo';

  @override
  String get dragOrTapQuadrant => 'Trascina o tocca un quadrante';

  @override
  String get previous => 'Precedente';

  @override
  String get skip => 'Salta';

  @override
  String get importTasks => 'Importa attività';

  @override
  String get widgetAppearance => 'Aspetto del widget';

  @override
  String get theme => 'Tema';

  @override
  String get systemTheme => 'Sistema';

  @override
  String get lightTheme => 'Chiaro';

  @override
  String get darkTheme => 'Scuro';

  @override
  String get background => 'Sfondo';

  @override
  String transparency(int percent) {
    return 'Trasparenza: $percent%';
  }

  @override
  String get textSize => 'Dimensione testo';

  @override
  String get small => 'Piccolo';

  @override
  String get medium => 'Medio';

  @override
  String get large => 'Grande';

  @override
  String get textColor => 'Colore testo';

  @override
  String get white => 'Bianco';

  @override
  String get black => 'Nero';

  @override
  String get quadrants => 'Quadranti';

  @override
  String get widgetUpdated => 'Widget aggiornato.';

  @override
  String get colorRed => 'Rosso';

  @override
  String get colorOrange => 'Arancione';

  @override
  String get colorYellow => 'Giallo';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorBlue => 'Blu';

  @override
  String get colorIndigo => 'Indaco';

  @override
  String get colorPurple => 'Viola';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorBrown => 'Marrone';

  @override
  String get colorGray => 'Grigio';

  @override
  String get colorTeal => 'Verde acqua';

  @override
  String get colorCyan => 'Ciano';

  @override
  String get colorLime => 'Lime';

  @override
  String get colorAmber => 'Ambra';

  @override
  String get colorDeepOrange => 'Arancione scuro';

  @override
  String get notificationChannelName => 'Attività prioritarie';

  @override
  String get notificationChannelDescription =>
      'Mostra le attività prioritarie della matrice di Eisenhower';

  @override
  String get createNewTask => 'Crea nuova attività';

  @override
  String taskCount(int count) {
    return '$count task';
  }

  @override
  String get persistentNotification => 'Notifica persistente';

  @override
  String get persistentNotificationDescription =>
      'Mostra le attività prioritarie nella barra delle notifiche';

  @override
  String get language => 'Lingua';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageSpanish => 'Spagnolo';

  @override
  String get languageFrench => 'Francese';

  @override
  String get languageGerman => 'Tedesco';

  @override
  String get languageChinese => 'Cinese';

  @override
  String get languagePortuguese => 'Portoghese';

  @override
  String get languageRussian => 'Russo';

  @override
  String get languageJapanese => 'Giapponese';

  @override
  String get languageArabic => 'Arabo';

  @override
  String get onboardingWelcomeTitle => 'Benvenuto nella Matrice di Eisenhower';

  @override
  String get onboardingWelcomeSubtitle =>
      'Lo strumento definitivo per dare priorità alle tue attività';

  @override
  String get onboardingWelcomeDescription =>
      'La Matrice di Eisenhower ti aiuta a organizzare le attività per urgenza e importanza, così puoi concentrarti su ciò che conta davvero.';

  @override
  String get onboardingGetStarted => 'Inizia';

  @override
  String get onboardingNotUrgent => 'Non Urgente';

  @override
  String get onboardingNotImportant => 'Non Importante';

  @override
  String get onboardingQ1Description => 'Fai ora';

  @override
  String get onboardingQ2Description => 'Pianifica';

  @override
  String get onboardingQ3Description => 'Delega';

  @override
  String get onboardingQ4Description => 'Elimina';

  @override
  String get onboardingFeaturesTitle => 'Funzioni Potenti';

  @override
  String get onboardingFeatureCategories => 'Organizza con Categorie';

  @override
  String get onboardingFeatureCategoriesDesc =>
      'Crea categorie personalizzate per raggruppare le tue attività per progetto o contesto';

  @override
  String get onboardingFeatureNotifications => 'Notifica persistente';

  @override
  String get onboardingFeatureNotificationsDesc =>
      'Consulta le tue attività prioritarie dalla barra delle notifiche';

  @override
  String get onboardingFeatureWidget => 'Widget Schermata Home';

  @override
  String get onboardingFeatureWidgetDesc =>
      'Visualizza le tue attività importanti a colpo d\'occhio senza aprire l\'app';

  @override
  String get onboardingFeatureSync => 'Sincronizzazione Cloud';

  @override
  String get onboardingFeatureSyncDesc =>
      'Le tue attività si sincronizzano automaticamente su tutti i tuoi dispositivi';

  @override
  String get onboardingContinue => 'Continua';

  @override
  String get onboardingSignInTitle => 'Accedi per Continuare';

  @override
  String get onboardingSignInDescription =>
      'Accedi con il tuo account Google per sincronizzare le tue attività e accedervi da qualsiasi luogo';

  @override
  String get onboardingSignInSuccess => 'Accesso effettuato con successo!';

  @override
  String get onboardingCategoriesTitle => 'Crea le Tue Categorie';

  @override
  String get onboardingCategoriesDescription =>
      'Le categorie ti aiutano a organizzare le attività per progetto, contesto o in qualsiasi modo preferisci';

  @override
  String get onboardingNoCategoriesYet =>
      'Nessuna categoria ancora. Crea la tua prima!';

  @override
  String get onboardingFinish => 'Termina';
}
