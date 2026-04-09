// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get authError => 'خطأ في المصادقة';

  @override
  String get signInSubtitle => 'نظم مهامك حسب الإلحاح والأهمية.';

  @override
  String get signInWithGoogle => 'تسجيل الدخول باستخدام Google';

  @override
  String get googleUser => 'مستخدم Google';

  @override
  String get settings => 'الإعدادات';

  @override
  String get profileAndSettings => 'الملف الشخصي والإعدادات';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get quadrantImportantUrgent => 'مهم، عاجل';

  @override
  String get quadrantImportantNotUrgent => 'مهم، غير عاجل';

  @override
  String get quadrantNotImportantUrgent => 'غير مهم، عاجل';

  @override
  String get quadrantNotImportantNotUrgent => 'غير مهم، غير عاجل';

  @override
  String get quadrantNamePriority => 'أولوية';

  @override
  String get quadrantNamePlan => 'خطط';

  @override
  String get quadrantNameDelegate => 'فوّض';

  @override
  String get quadrantNameEliminate => 'احذف';

  @override
  String get yourEisenhowerMatrix => 'مصفوفة أيزنهاور الخاصة بك';

  @override
  String greeting(String name) {
    return 'مرحباً، $name!';
  }

  @override
  String get columnView => 'عرض الأعمدة';

  @override
  String get gridView => 'عرض الشبكة';

  @override
  String get empty => 'فارغ';

  @override
  String get newTask => 'مهمة جديدة';

  @override
  String get editTask => 'تعديل المهمة';

  @override
  String get taskTitle => 'العنوان';

  @override
  String get taskDescription => 'الوصف';

  @override
  String get priority => 'الأولوية';

  @override
  String get important => 'مهم';

  @override
  String get urgent => 'عاجل';

  @override
  String get quadrant => 'ربع';

  @override
  String get category => 'الفئة';

  @override
  String get createCategory => 'إنشاء فئة';

  @override
  String get dueDate => 'تاريخ الاستحقاق';

  @override
  String get removeDescription => 'إزالة الوصف';

  @override
  String get removeDescriptionConfirm => 'هل تريد إزالة الوصف؟';

  @override
  String get removeDueDate => 'إزالة تاريخ الاستحقاق';

  @override
  String get removeDueDateConfirm => 'هل تريد إزالة تاريخ الاستحقاق؟';

  @override
  String get deleteTask => 'حذف المهمة';

  @override
  String get deleteTaskConfirm => 'هل تريد حذف هذه المهمة؟';

  @override
  String get save => 'حفظ';

  @override
  String get createTask => 'إنشاء مهمة';

  @override
  String get delete => 'حذف';

  @override
  String get remove => 'إزالة';

  @override
  String get cancel => 'إلغاء';

  @override
  String dueDateLabel(String date) {
    return 'الاستحقاق: $date';
  }

  @override
  String get completedTasks => 'المهام المكتملة';

  @override
  String get loadingError => 'خطأ في التحميل';

  @override
  String get noCompletedTasks => 'لا توجد مهام مكتملة';

  @override
  String completedOn(String date) {
    return 'اكتمل في $date';
  }

  @override
  String get categories => 'الفئات';

  @override
  String get categoryManagement => 'إدارة الفئات';

  @override
  String get emoji => 'رمز تعبيري';

  @override
  String get categoryName => 'اسم الفئة';

  @override
  String get add => 'إضافة';

  @override
  String get close => 'إغلاق';

  @override
  String get deleteCategory => 'حذف الفئة';

  @override
  String deleteCategoryConfirm(String name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String get deleteCategoryWarning => 'ستفقد المهام المرتبطة فئتها.';

  @override
  String get importFromGoogleTasks => 'استيراد من Google Tasks';

  @override
  String get loadingGoogleTasks => 'جاري تحميل مهام Google...';

  @override
  String get unknownError => 'خطأ غير معروف';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noGoogleTasksFound => 'لم يتم العثور على مهام في Google Tasks.';

  @override
  String continueWithSelected(int count) {
    return 'متابعة ($count)';
  }

  @override
  String get selectAll => 'تحديد الكل';

  @override
  String get deselectAll => 'إلغاء تحديد الكل';

  @override
  String assignQuadrant(int assigned, int total) {
    return 'تعيين ربع ($assigned/$total)';
  }

  @override
  String get quadrantAssigned => 'تم تعيين الربع ✓ — اضغط على آخر لتغييره';

  @override
  String get dragOrTapQuadrant => 'اسحب أو اضغط على ربع';

  @override
  String get previous => 'السابق';

  @override
  String get skip => 'تخطي';

  @override
  String get importTasks => 'استيراد المهام';

  @override
  String get widgetAppearance => 'مظهر الأداة';

  @override
  String get theme => 'السمة';

  @override
  String get systemTheme => 'النظام';

  @override
  String get lightTheme => 'فاتح';

  @override
  String get darkTheme => 'داكن';

  @override
  String get background => 'الخلفية';

  @override
  String transparency(int percent) {
    return 'الشفافية: $percent%';
  }

  @override
  String get textSize => 'حجم النص';

  @override
  String get small => 'صغير';

  @override
  String get medium => 'متوسط';

  @override
  String get large => 'كبير';

  @override
  String get textColor => 'لون النص';

  @override
  String get white => 'أبيض';

  @override
  String get black => 'أسود';

  @override
  String get quadrants => 'الأرباع';

  @override
  String get widgetUpdated => 'تم تحديث الأداة.';

  @override
  String get colorRed => 'أحمر';

  @override
  String get colorOrange => 'برتقالي';

  @override
  String get colorYellow => 'أصفر';

  @override
  String get colorGreen => 'أخضر';

  @override
  String get colorBlue => 'أزرق';

  @override
  String get colorIndigo => 'نيلي';

  @override
  String get colorPurple => 'أرجواني';

  @override
  String get colorPink => 'وردي';

  @override
  String get colorBrown => 'بني';

  @override
  String get colorGray => 'رمادي';

  @override
  String get colorTeal => 'أزرق مخضر';

  @override
  String get colorCyan => 'سماوي';

  @override
  String get colorLime => 'ليموني';

  @override
  String get colorAmber => 'كهرماني';

  @override
  String get colorDeepOrange => 'برتقالي داكن';

  @override
  String get notificationChannelName => 'المهام ذات الأولوية';

  @override
  String get notificationChannelDescription =>
      'عرض المهام ذات الأولوية من مصفوفة أيزنهاور';

  @override
  String get createNewTask => 'إنشاء مهمة جديدة';

  @override
  String taskCount(int count) {
    return '$count مهام';
  }

  @override
  String get persistentNotification => 'إشعار دائم';

  @override
  String get persistentNotificationDescription =>
      'عرض المهام ذات الأولوية في شريط الإشعارات';

  @override
  String get language => 'اللغة';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageItalian => 'الإيطالية';

  @override
  String get languageSpanish => 'الإسبانية';

  @override
  String get languageFrench => 'الفرنسية';

  @override
  String get languageGerman => 'الألمانية';

  @override
  String get languageChinese => 'الصينية';

  @override
  String get languagePortuguese => 'البرتغالية';

  @override
  String get languageRussian => 'الروسية';

  @override
  String get languageJapanese => 'اليابانية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get onboardingWelcomeTitle => 'مرحبًا بك في مصفوفة أيزنهاور';

  @override
  String get onboardingWelcomeSubtitle =>
      'الأداة المثالية لترتيب أولويات مهامك';

  @override
  String get onboardingWelcomeDescription =>
      'تساعدك مصفوفة أيزنهاور على تنظيم المهام حسب الإلحاح والأهمية، حتى تتمكن من التركيز على ما يهم حقًا.';

  @override
  String get onboardingGetStarted => 'ابدأ';

  @override
  String get onboardingNotUrgent => 'غير عاجل';

  @override
  String get onboardingNotImportant => 'غير مهم';

  @override
  String get onboardingQ1Description => 'نفذ الآن';

  @override
  String get onboardingQ2Description => 'جدولة';

  @override
  String get onboardingQ3Description => 'تفويض';

  @override
  String get onboardingQ4Description => 'حذف';

  @override
  String get onboardingFeaturesTitle => 'ميزات قوية';

  @override
  String get onboardingFeatureCategories => 'التنظيم بالفئات';

  @override
  String get onboardingFeatureCategoriesDesc =>
      'إنشاء فئات مخصصة لتجميع مهامك حسب المشروع أو السياق';

  @override
  String get onboardingFeatureNotifications => 'إشعار مستمر';

  @override
  String get onboardingFeatureNotificationsDesc =>
      'تصفح مهامك ذات الأولوية من شريط الإشعارات';

  @override
  String get onboardingFeatureWidget => 'أداة الشاشة الرئيسية';

  @override
  String get onboardingFeatureWidgetDesc =>
      'شاهد مهامك المهمة بلمحة واحدة دون فتح التطبيق';

  @override
  String get onboardingFeatureSync => 'المزامنة السحابية';

  @override
  String get onboardingFeatureSyncDesc =>
      'تتم مزامنة مهامك تلقائيًا عبر جميع أجهزتك';

  @override
  String get onboardingContinue => 'متابعة';

  @override
  String get onboardingSignInTitle => 'تسجيل الدخول للمتابعة';

  @override
  String get onboardingSignInDescription =>
      'سجل الدخول باستخدام حساب Google الخاص بك لمزامنة مهامك والوصول إليها من أي مكان';

  @override
  String get onboardingSignInSuccess => 'تم تسجيل الدخول بنجاح!';

  @override
  String get onboardingCategoriesTitle => 'إنشاء فئاتك';

  @override
  String get onboardingCategoriesDescription =>
      'تساعدك الفئات على تنظيم المهام حسب المشروع أو السياق أو بأي طريقة تفضلها';

  @override
  String get onboardingNoCategoriesYet => 'لا توجد فئات بعد. أنشئ فئتك الأولى!';

  @override
  String get onboardingFinish => 'إنهاء';
}
