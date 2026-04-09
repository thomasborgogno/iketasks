// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get authError => 'Authentication error';

  @override
  String get signInSubtitle => 'Organize your tasks by urgency and importance.';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get googleUser => 'Google User';

  @override
  String get settings => 'Settings';

  @override
  String get profileAndSettings => 'Profile and settings';

  @override
  String get signOut => 'Sign out';

  @override
  String get quadrantImportantUrgent => 'Important, urgent';

  @override
  String get quadrantImportantNotUrgent => 'Important, not urgent';

  @override
  String get quadrantNotImportantUrgent => 'Not important, urgent';

  @override
  String get quadrantNotImportantNotUrgent => 'Not important, not urgent';

  @override
  String get quadrantNamePriority => 'Priority';

  @override
  String get quadrantNamePlan => 'Plan';

  @override
  String get quadrantNameDelegate => 'Delegate';

  @override
  String get quadrantNameEliminate => 'Eliminate';

  @override
  String get yourEisenhowerMatrix => 'Your Eisenhower Matrix';

  @override
  String greeting(String name) {
    return 'Hello, $name!';
  }

  @override
  String get columnView => 'Column view';

  @override
  String get gridView => 'Grid view';

  @override
  String get empty => 'Empty';

  @override
  String get newTask => 'New task';

  @override
  String get editTask => 'Edit task';

  @override
  String get taskTitle => 'Title';

  @override
  String get taskDescription => 'Description';

  @override
  String get priority => 'Priority';

  @override
  String get important => 'Important';

  @override
  String get urgent => 'Urgent';

  @override
  String get quadrant => 'Quadrant';

  @override
  String get category => 'Category';

  @override
  String get createCategory => 'Create a category';

  @override
  String get dueDate => 'Due date';

  @override
  String get removeDescription => 'Remove description';

  @override
  String get removeDescriptionConfirm =>
      'Do you want to remove the description?';

  @override
  String get removeDueDate => 'Remove due date';

  @override
  String get removeDueDateConfirm => 'Do you want to remove the due date?';

  @override
  String get deleteTask => 'Delete task';

  @override
  String get deleteTaskConfirm => 'Do you want to delete this task?';

  @override
  String get save => 'Save';

  @override
  String get createTask => 'Create task';

  @override
  String get delete => 'Delete';

  @override
  String get remove => 'Remove';

  @override
  String get cancel => 'Cancel';

  @override
  String dueDateLabel(String date) {
    return 'Due: $date';
  }

  @override
  String get completedTasks => 'Completed tasks';

  @override
  String get loadingError => 'Loading error';

  @override
  String get noCompletedTasks => 'No completed tasks';

  @override
  String completedOn(String date) {
    return 'Completed on $date';
  }

  @override
  String get categories => 'Categories';

  @override
  String get categoryManagement => 'Category management';

  @override
  String get emoji => 'Emoji';

  @override
  String get categoryName => 'Category name';

  @override
  String get add => 'Add';

  @override
  String get close => 'Close';

  @override
  String get deleteCategory => 'Delete category';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deleteCategoryWarning =>
      'Associated tasks will lose their category.';

  @override
  String get importFromGoogleTasks => 'Import from Google Tasks';

  @override
  String get loadingGoogleTasks => 'Loading Google Tasks...';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get retry => 'Retry';

  @override
  String get noGoogleTasksFound => 'No tasks found on Google Tasks.';

  @override
  String continueWithSelected(int count) {
    return 'Continue ($count)';
  }

  @override
  String get selectAll => 'Select all';

  @override
  String get deselectAll => 'Deselect all';

  @override
  String assignQuadrant(int assigned, int total) {
    return 'Assign quadrant ($assigned/$total)';
  }

  @override
  String get quadrantAssigned =>
      'Quadrant assigned ✓ — tap another to change it';

  @override
  String get dragOrTapQuadrant => 'Drag or tap a quadrant';

  @override
  String get previous => 'Previous';

  @override
  String get skip => 'Skip';

  @override
  String get importTasks => 'Import tasks';

  @override
  String get widgetAppearance => 'Widget appearance';

  @override
  String get theme => 'Theme';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get background => 'Background';

  @override
  String transparency(int percent) {
    return 'Transparency: $percent%';
  }

  @override
  String get textSize => 'Text size';

  @override
  String get small => 'Small';

  @override
  String get medium => 'Medium';

  @override
  String get large => 'Large';

  @override
  String get textColor => 'Text color';

  @override
  String get white => 'White';

  @override
  String get black => 'Black';

  @override
  String get quadrants => 'Quadrants';

  @override
  String get widgetUpdated => 'Widget updated.';

  @override
  String get colorRed => 'Red';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorBrown => 'Brown';

  @override
  String get colorGray => 'Gray';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorCyan => 'Cyan';

  @override
  String get colorLime => 'Lime';

  @override
  String get colorAmber => 'Amber';

  @override
  String get colorDeepOrange => 'Deep Orange';

  @override
  String get notificationChannelName => 'Priority tasks';

  @override
  String get notificationChannelDescription =>
      'Show priority tasks from the Eisenhower Matrix';

  @override
  String get createNewTask => 'Create new task';

  @override
  String taskCount(int count) {
    return '$count tasks';
  }

  @override
  String get persistentNotification => 'Persistent notification';

  @override
  String get persistentNotificationDescription =>
      'Show priority tasks in the notification bar';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italian';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageFrench => 'French';

  @override
  String get languageGerman => 'German';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get languageArabic => 'Arabic';
}
