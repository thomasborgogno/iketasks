// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get authError => 'Erreur d\'authentification';

  @override
  String get signInSubtitle =>
      'Organisez vos tâches par urgence et importance.';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get googleUser => 'Utilisateur Google';

  @override
  String get settings => 'Paramètres';

  @override
  String get profileAndSettings => 'Profil et paramètres';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get quadrantImportantUrgent => 'Important, urgent';

  @override
  String get quadrantImportantNotUrgent => 'Important, non urgent';

  @override
  String get quadrantNotImportantUrgent => 'Non important, urgent';

  @override
  String get quadrantNotImportantNotUrgent => 'Non important, non urgent';

  @override
  String get quadrantNamePriority => 'Priorité';

  @override
  String get quadrantNamePlan => 'Planifier';

  @override
  String get quadrantNameDelegate => 'Déléguer';

  @override
  String get quadrantNameEliminate => 'Éliminer';

  @override
  String get yourEisenhowerMatrix => 'Votre matrice d\'Eisenhower';

  @override
  String greeting(String name) {
    return 'Bonjour, $name !';
  }

  @override
  String get columnView => 'Vue en colonnes';

  @override
  String get gridView => 'Vue en grille';

  @override
  String get empty => 'Vide';

  @override
  String get newTask => 'Nouvelle tâche';

  @override
  String get editTask => 'Modifier la tâche';

  @override
  String get taskTitle => 'Titre';

  @override
  String get taskDescription => 'Description';

  @override
  String get priority => 'Priorité';

  @override
  String get important => 'Important';

  @override
  String get urgent => 'Urgent';

  @override
  String get quadrant => 'Quadrant';

  @override
  String get category => 'Catégorie';

  @override
  String get createCategory => 'Créer une catégorie';

  @override
  String get dueDate => 'Date d\'échéance';

  @override
  String get removeDescription => 'Supprimer la description';

  @override
  String get removeDescriptionConfirm =>
      'Voulez-vous supprimer la description ?';

  @override
  String get removeDueDate => 'Supprimer la date d\'échéance';

  @override
  String get removeDueDateConfirm =>
      'Voulez-vous supprimer la date d\'échéance ?';

  @override
  String get deleteTask => 'Supprimer la tâche';

  @override
  String get deleteTaskConfirm => 'Voulez-vous supprimer cette tâche ?';

  @override
  String get save => 'Enregistrer';

  @override
  String get createTask => 'Créer une tâche';

  @override
  String get delete => 'Supprimer';

  @override
  String get remove => 'Retirer';

  @override
  String get cancel => 'Annuler';

  @override
  String dueDateLabel(String date) {
    return 'Échéance : $date';
  }

  @override
  String get completedTasks => 'Tâches terminées';

  @override
  String get loadingError => 'Erreur de chargement';

  @override
  String get noCompletedTasks => 'Aucune tâche terminée';

  @override
  String completedOn(String date) {
    return 'Terminée le $date';
  }

  @override
  String get categories => 'Catégories';

  @override
  String get categoryManagement => 'Gestion des catégories';

  @override
  String get emoji => 'Emoji';

  @override
  String get categoryName => 'Nom de la catégorie';

  @override
  String get add => 'Ajouter';

  @override
  String get close => 'Fermer';

  @override
  String get deleteCategory => 'Supprimer la catégorie';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Supprimer \"$name\" ?';
  }

  @override
  String get deleteCategoryWarning =>
      'Les tâches associées perdront leur catégorie.';

  @override
  String get importFromGoogleTasks => 'Importer depuis Google Tasks';

  @override
  String get loadingGoogleTasks => 'Chargement des tâches Google...';

  @override
  String get unknownError => 'Erreur inconnue';

  @override
  String get retry => 'Réessayer';

  @override
  String get noGoogleTasksFound => 'Aucune tâche trouvée sur Google Tasks.';

  @override
  String continueWithSelected(int count) {
    return 'Continuer ($count)';
  }

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get deselectAll => 'Tout désélectionner';

  @override
  String assignQuadrant(int assigned, int total) {
    return 'Assigner un quadrant ($assigned/$total)';
  }

  @override
  String get quadrantAssigned =>
      'Quadrant assigné ✓ — appuyez sur un autre pour le changer';

  @override
  String get dragOrTapQuadrant => 'Faites glisser ou appuyez sur un quadrant';

  @override
  String get previous => 'Précédent';

  @override
  String get skip => 'Passer';

  @override
  String get importTasks => 'Importer les tâches';

  @override
  String get widgetAppearance => 'Apparence du widget';

  @override
  String get theme => 'Thème';

  @override
  String get systemTheme => 'Système';

  @override
  String get lightTheme => 'Clair';

  @override
  String get darkTheme => 'Sombre';

  @override
  String get background => 'Arrière-plan';

  @override
  String transparency(int percent) {
    return 'Transparence : $percent%';
  }

  @override
  String get textSize => 'Taille du texte';

  @override
  String get small => 'Petit';

  @override
  String get medium => 'Moyen';

  @override
  String get large => 'Grand';

  @override
  String get textColor => 'Couleur du texte';

  @override
  String get white => 'Blanc';

  @override
  String get black => 'Noir';

  @override
  String get quadrants => 'Quadrants';

  @override
  String get widgetUpdated => 'Widget mis à jour.';

  @override
  String get colorRed => 'Rouge';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorYellow => 'Jaune';

  @override
  String get colorGreen => 'Vert';

  @override
  String get colorBlue => 'Bleu';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorPurple => 'Violet';

  @override
  String get colorPink => 'Rose';

  @override
  String get colorBrown => 'Marron';

  @override
  String get colorGray => 'Gris';

  @override
  String get colorTeal => 'Sarcelle';

  @override
  String get colorCyan => 'Cyan';

  @override
  String get colorLime => 'Citron vert';

  @override
  String get colorAmber => 'Ambre';

  @override
  String get colorDeepOrange => 'Orange foncé';

  @override
  String get notificationChannelName => 'Tâches prioritaires';

  @override
  String get notificationChannelDescription =>
      'Afficher les tâches prioritaires de la matrice d\'Eisenhower';

  @override
  String get createNewTask => 'Créer une nouvelle tâche';

  @override
  String taskCount(int count) {
    return '$count tâches';
  }

  @override
  String get persistentNotification => 'Notification persistante';

  @override
  String get persistentNotificationDescription =>
      'Afficher les tâches prioritaires dans la barre de notifications';

  @override
  String get language => 'Langue';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageItalian => 'Italien';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Allemand';

  @override
  String get languageChinese => 'Chinois';

  @override
  String get languagePortuguese => 'Portugais';

  @override
  String get languageRussian => 'Russe';

  @override
  String get languageJapanese => 'Japonais';

  @override
  String get languageArabic => 'Arabe';
}
