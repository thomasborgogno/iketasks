// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get authError => 'Ошибка аутентификации';

  @override
  String get signInSubtitle =>
      'Организуйте свои задачи по срочности и важности.';

  @override
  String get signInWithGoogle => 'Войти через Google';

  @override
  String get googleUser => 'Пользователь Google';

  @override
  String get settings => 'Настройки';

  @override
  String get profileAndSettings => 'Профиль и настройки';

  @override
  String get signOut => 'Выйти';

  @override
  String get quadrantImportantUrgent => 'Важно, срочно';

  @override
  String get quadrantImportantNotUrgent => 'Важно, не срочно';

  @override
  String get quadrantNotImportantUrgent => 'Не важно, срочно';

  @override
  String get quadrantNotImportantNotUrgent => 'Не важно, не срочно';

  @override
  String get quadrantNamePriority => 'Приоритет';

  @override
  String get quadrantNamePlan => 'Планировать';

  @override
  String get quadrantNameDelegate => 'Делегировать';

  @override
  String get quadrantNameEliminate => 'Устранить';

  @override
  String get yourEisenhowerMatrix => 'Ваша матрица Эйзенхауэра';

  @override
  String greeting(String name) {
    return 'Привет, $name!';
  }

  @override
  String get columnView => 'Вид столбцов';

  @override
  String get gridView => 'Вид сетки';

  @override
  String get empty => 'Пусто';

  @override
  String get newTask => 'Новая задача';

  @override
  String get editTask => 'Редактировать задачу';

  @override
  String get taskTitle => 'Название';

  @override
  String get taskDescription => 'Описание';

  @override
  String get priority => 'Приоритет';

  @override
  String get important => 'Важно';

  @override
  String get urgent => 'Срочно';

  @override
  String get quadrant => 'Квадрант';

  @override
  String get category => 'Категория';

  @override
  String get createCategory => 'Создать категорию';

  @override
  String get dueDate => 'Срок выполнения';

  @override
  String get removeDescription => 'Удалить описание';

  @override
  String get removeDescriptionConfirm => 'Вы хотите удалить описание?';

  @override
  String get removeDueDate => 'Удалить срок выполнения';

  @override
  String get removeDueDateConfirm => 'Вы хотите удалить срок выполнения?';

  @override
  String get deleteTask => 'Удалить задачу';

  @override
  String get deleteTaskConfirm => 'Вы хотите удалить эту задачу?';

  @override
  String get save => 'Сохранить';

  @override
  String get createTask => 'Создать задачу';

  @override
  String get delete => 'Удалить';

  @override
  String get remove => 'Убрать';

  @override
  String get cancel => 'Отмена';

  @override
  String dueDateLabel(String date) {
    return 'Срок: $date';
  }

  @override
  String get completedTasks => 'Завершенные задачи';

  @override
  String get loadingError => 'Ошибка загрузки';

  @override
  String get noCompletedTasks => 'Нет завершенных задач';

  @override
  String completedOn(String date) {
    return 'Завершено $date';
  }

  @override
  String get categories => 'Категории';

  @override
  String get categoryManagement => 'Управление категориями';

  @override
  String get emoji => 'Эмодзи';

  @override
  String get categoryName => 'Название категории';

  @override
  String get add => 'Добавить';

  @override
  String get close => 'Закрыть';

  @override
  String get deleteCategory => 'Удалить категорию';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Удалить \"$name\"?';
  }

  @override
  String get deleteCategoryWarning =>
      'Связанные задачи потеряют свою категорию.';

  @override
  String get importFromGoogleTasks => 'Импорт из Google Tasks';

  @override
  String get loadingGoogleTasks => 'Загрузка задач Google...';

  @override
  String get unknownError => 'Неизвестная ошибка';

  @override
  String get retry => 'Повторить';

  @override
  String get noGoogleTasksFound => 'Задачи в Google Tasks не найдены.';

  @override
  String continueWithSelected(int count) {
    return 'Продолжить ($count)';
  }

  @override
  String get selectAll => 'Выбрать все';

  @override
  String get deselectAll => 'Отменить выбор';

  @override
  String assignQuadrant(int assigned, int total) {
    return 'Назначить квадрант ($assigned/$total)';
  }

  @override
  String get quadrantAssigned =>
      'Квадрант назначен ✓ — нажмите на другой, чтобы изменить';

  @override
  String get dragOrTapQuadrant => 'Перетащите или нажмите на квадрант';

  @override
  String get previous => 'Назад';

  @override
  String get skip => 'Пропустить';

  @override
  String get importTasks => 'Импортировать задачи';

  @override
  String get widgetAppearance => 'Внешний вид виджета';

  @override
  String get theme => 'Тема';

  @override
  String get systemTheme => 'Система';

  @override
  String get lightTheme => 'Светлая';

  @override
  String get darkTheme => 'Темная';

  @override
  String get background => 'Фон';

  @override
  String transparency(int percent) {
    return 'Прозрачность: $percent%';
  }

  @override
  String get textSize => 'Размер текста';

  @override
  String get small => 'Маленький';

  @override
  String get medium => 'Средний';

  @override
  String get large => 'Большой';

  @override
  String get textColor => 'Цвет текста';

  @override
  String get white => 'Белый';

  @override
  String get black => 'Черный';

  @override
  String get quadrants => 'Квадранты';

  @override
  String get widgetUpdated => 'Виджет обновлен.';

  @override
  String get colorRed => 'Красный';

  @override
  String get colorOrange => 'Оранжевый';

  @override
  String get colorYellow => 'Желтый';

  @override
  String get colorGreen => 'Зеленый';

  @override
  String get colorBlue => 'Синий';

  @override
  String get colorIndigo => 'Индиго';

  @override
  String get colorPurple => 'Фиолетовый';

  @override
  String get colorPink => 'Розовый';

  @override
  String get colorBrown => 'Коричневый';

  @override
  String get colorGray => 'Серый';

  @override
  String get colorTeal => 'Бирюзовый';

  @override
  String get colorCyan => 'Голубой';

  @override
  String get colorLime => 'Лаймовый';

  @override
  String get colorAmber => 'Янтарный';

  @override
  String get colorDeepOrange => 'Темно-оранжевый';

  @override
  String get notificationChannelName => 'Приоритетные задачи';

  @override
  String get notificationChannelDescription =>
      'Показать приоритетные задачи из матрицы Эйзенхауэра';

  @override
  String get createNewTask => 'Создать новую задачу';

  @override
  String taskCount(int count) {
    return '$count задач';
  }

  @override
  String get persistentNotification => 'Постоянное уведомление';

  @override
  String get persistentNotificationDescription =>
      'Показывать приоритетные задачи в панели уведомлений';

  @override
  String get language => 'Язык';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageItalian => 'Итальянский';

  @override
  String get languageSpanish => 'Испанский';

  @override
  String get languageFrench => 'Французский';

  @override
  String get languageGerman => 'Немецкий';

  @override
  String get languageChinese => 'Китайский';

  @override
  String get languagePortuguese => 'Португальский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageJapanese => 'Японский';

  @override
  String get languageArabic => 'Арабский';

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать в Матрицу Эйзенхауэра';

  @override
  String get onboardingWelcomeSubtitle =>
      'Идеальный инструмент для расстановки приоритетов';

  @override
  String get onboardingWelcomeDescription =>
      'Матрица Эйзенхауэра помогает вам организовать задачи по срочности и важности, чтобы вы могли сосредоточиться на том, что действительно важно.';

  @override
  String get onboardingGetStarted => 'Начать';

  @override
  String get onboardingNotUrgent => 'Не Срочно';

  @override
  String get onboardingNotImportant => 'Не Важно';

  @override
  String get onboardingQ1Description => 'Сделать сейчас';

  @override
  String get onboardingQ2Description => 'Запланировать';

  @override
  String get onboardingQ3Description => 'Делегировать';

  @override
  String get onboardingQ4Description => 'Исключить';

  @override
  String get onboardingFeaturesTitle => 'Мощные Функции';

  @override
  String get onboardingFeatureCategories => 'Организация с Категориями';

  @override
  String get onboardingFeatureCategoriesDesc =>
      'Создавайте пользовательские категории для группировки задач по проектам или контексту';

  @override
  String get onboardingFeatureNotifications => 'Постоянное уведомление';

  @override
  String get onboardingFeatureNotificationsDesc =>
      'Просматривайте приоритетные задачи из панели уведомлений';

  @override
  String get onboardingFeatureWidget => 'Виджет Главного Экрана';

  @override
  String get onboardingFeatureWidgetDesc =>
      'Просматривайте важные задачи с одного взгляда без открытия приложения';

  @override
  String get onboardingFeatureSync => 'Облачная Синхронизация';

  @override
  String get onboardingFeatureSyncDesc =>
      'Ваши задачи автоматически синхронизируются на всех ваших устройствах';

  @override
  String get onboardingContinue => 'Продолжить';

  @override
  String get onboardingSignInTitle => 'Войдите, чтобы Продолжить';

  @override
  String get onboardingSignInDescription =>
      'Войдите с помощью учетной записи Google для синхронизации задач и доступа к ним из любого места';

  @override
  String get onboardingSignInSuccess => 'Вход выполнен успешно!';

  @override
  String get onboardingCategoriesTitle => 'Создайте свои Категории';

  @override
  String get onboardingCategoriesDescription =>
      'Категории помогают организовать задачи по проектам, контексту или любым другим способом';

  @override
  String get onboardingNoCategoriesYet =>
      'Категорий пока нет. Создайте свою первую!';

  @override
  String get onboardingFinish => 'Завершить';
}
