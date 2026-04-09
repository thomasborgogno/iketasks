// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get authError => 'Error de autenticación';

  @override
  String get signInSubtitle =>
      'Organiza tus tareas por urgencia e importancia.';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get googleUser => 'Usuario de Google';

  @override
  String get settings => 'Configuración';

  @override
  String get profileAndSettings => 'Perfil y configuración';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get quadrantImportantUrgent => 'Importante, urgente';

  @override
  String get quadrantImportantNotUrgent => 'Importante, no urgente';

  @override
  String get quadrantNotImportantUrgent => 'No importante, urgente';

  @override
  String get quadrantNotImportantNotUrgent => 'No importante, no urgente';

  @override
  String get quadrantNamePriority => 'Prioridad';

  @override
  String get quadrantNamePlan => 'Planificar';

  @override
  String get quadrantNameDelegate => 'Delegar';

  @override
  String get quadrantNameEliminate => 'Eliminar';

  @override
  String get yourEisenhowerMatrix => 'Tu matriz de Eisenhower';

  @override
  String greeting(String name) {
    return '¡Hola, $name!';
  }

  @override
  String get columnView => 'Vista de columnas';

  @override
  String get gridView => 'Vista de cuadrícula';

  @override
  String get empty => 'Vacío';

  @override
  String get newTask => 'Nueva tarea';

  @override
  String get editTask => 'Editar tarea';

  @override
  String get taskTitle => 'Título';

  @override
  String get taskDescription => 'Descripción';

  @override
  String get priority => 'Prioridad';

  @override
  String get important => 'Importante';

  @override
  String get urgent => 'Urgente';

  @override
  String get quadrant => 'Cuadrante';

  @override
  String get category => 'Categoría';

  @override
  String get createCategory => 'Crear una categoría';

  @override
  String get dueDate => 'Fecha límite';

  @override
  String get removeDescription => 'Eliminar descripción';

  @override
  String get removeDescriptionConfirm => '¿Quieres eliminar la descripción?';

  @override
  String get removeDueDate => 'Eliminar fecha límite';

  @override
  String get removeDueDateConfirm => '¿Quieres eliminar la fecha límite?';

  @override
  String get deleteTask => 'Eliminar tarea';

  @override
  String get deleteTaskConfirm => '¿Quieres eliminar esta tarea?';

  @override
  String get save => 'Guardar';

  @override
  String get createTask => 'Crear tarea';

  @override
  String get delete => 'Eliminar';

  @override
  String get remove => 'Quitar';

  @override
  String get cancel => 'Cancelar';

  @override
  String dueDateLabel(String date) {
    return 'Vence: $date';
  }

  @override
  String get completedTasks => 'Tareas completadas';

  @override
  String get loadingError => 'Error de carga';

  @override
  String get noCompletedTasks => 'No hay tareas completadas';

  @override
  String completedOn(String date) {
    return 'Completada el $date';
  }

  @override
  String get categories => 'Categorías';

  @override
  String get categoryManagement => 'Gestión de categorías';

  @override
  String get emoji => 'Emoji';

  @override
  String get categoryName => 'Nombre de la categoría';

  @override
  String get add => 'Agregar';

  @override
  String get close => 'Cerrar';

  @override
  String get deleteCategory => 'Eliminar categoría';

  @override
  String deleteCategoryConfirm(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get deleteCategoryWarning =>
      'Las tareas asociadas perderán su categoría.';

  @override
  String get importFromGoogleTasks => 'Importar de Google Tasks';

  @override
  String get loadingGoogleTasks => 'Cargando tareas de Google...';

  @override
  String get unknownError => 'Error desconocido';

  @override
  String get retry => 'Reintentar';

  @override
  String get noGoogleTasksFound => 'No se encontraron tareas en Google Tasks.';

  @override
  String continueWithSelected(int count) {
    return 'Continuar ($count)';
  }

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get deselectAll => 'Deseleccionar todo';

  @override
  String assignQuadrant(int assigned, int total) {
    return 'Asignar cuadrante ($assigned/$total)';
  }

  @override
  String get quadrantAssigned =>
      'Cuadrante asignado ✓ — toca otro para cambiarlo';

  @override
  String get dragOrTapQuadrant => 'Arrastra o toca un cuadrante';

  @override
  String get previous => 'Anterior';

  @override
  String get skip => 'Omitir';

  @override
  String get importTasks => 'Importar tareas';

  @override
  String get widgetAppearance => 'Apariencia del widget';

  @override
  String get theme => 'Tema';

  @override
  String get systemTheme => 'Sistema';

  @override
  String get lightTheme => 'Claro';

  @override
  String get darkTheme => 'Oscuro';

  @override
  String get background => 'Fondo';

  @override
  String transparency(int percent) {
    return 'Transparencia: $percent%';
  }

  @override
  String get textSize => 'Tamaño del texto';

  @override
  String get small => 'Pequeño';

  @override
  String get medium => 'Mediano';

  @override
  String get large => 'Grande';

  @override
  String get textColor => 'Color del texto';

  @override
  String get white => 'Blanco';

  @override
  String get black => 'Negro';

  @override
  String get quadrants => 'Cuadrantes';

  @override
  String get widgetUpdated => 'Widget actualizado.';

  @override
  String get colorRed => 'Rojo';

  @override
  String get colorOrange => 'Naranja';

  @override
  String get colorYellow => 'Amarillo';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorIndigo => 'Índigo';

  @override
  String get colorPurple => 'Púrpura';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorBrown => 'Marrón';

  @override
  String get colorGray => 'Gris';

  @override
  String get colorTeal => 'Verde azulado';

  @override
  String get colorCyan => 'Cian';

  @override
  String get colorLime => 'Lima';

  @override
  String get colorAmber => 'Ámbar';

  @override
  String get colorDeepOrange => 'Naranja oscuro';

  @override
  String get notificationChannelName => 'Tareas prioritarias';

  @override
  String get notificationChannelDescription =>
      'Mostrar las tareas prioritarias de la matriz de Eisenhower';

  @override
  String get createNewTask => 'Crear nueva tarea';

  @override
  String taskCount(int count) {
    return '$count tareas';
  }

  @override
  String get persistentNotification => 'Notificación persistente';

  @override
  String get persistentNotificationDescription =>
      'Mostrar tareas prioritarias en la barra de notificaciones';

  @override
  String get language => 'Idioma';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageGerman => 'Alemán';

  @override
  String get languageChinese => 'Chino';

  @override
  String get languagePortuguese => 'Portugués';

  @override
  String get languageRussian => 'Ruso';

  @override
  String get languageJapanese => 'Japonés';

  @override
  String get languageArabic => 'Árabe';
}
