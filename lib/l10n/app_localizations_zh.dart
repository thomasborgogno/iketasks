// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get authError => '身份验证错误';

  @override
  String get signInSubtitle => '按紧急性和重要性组织您的任务。';

  @override
  String get signInWithGoogle => '使用 Google 登录';

  @override
  String get googleUser => 'Google 用户';

  @override
  String get settings => '设置';

  @override
  String get profileAndSettings => '个人资料和设置';

  @override
  String get signOut => '退出登录';

  @override
  String get quadrantImportantUrgent => '重要且紧急';

  @override
  String get quadrantImportantNotUrgent => '重要但不紧急';

  @override
  String get quadrantNotImportantUrgent => '不重要但紧急';

  @override
  String get quadrantNotImportantNotUrgent => '不重要且不紧急';

  @override
  String get quadrantNamePriority => '优先';

  @override
  String get quadrantNamePlan => '计划';

  @override
  String get quadrantNameDelegate => '委托';

  @override
  String get quadrantNameEliminate => '消除';

  @override
  String get yourEisenhowerMatrix => '您的艾森豪威尔矩阵';

  @override
  String greeting(String name) {
    return '你好，$name！';
  }

  @override
  String get columnView => '列视图';

  @override
  String get gridView => '网格视图';

  @override
  String get empty => '空';

  @override
  String get newTask => '新任务';

  @override
  String get editTask => '编辑任务';

  @override
  String get taskTitle => '标题';

  @override
  String get taskDescription => '描述';

  @override
  String get priority => '优先级';

  @override
  String get important => '重要';

  @override
  String get urgent => '紧急';

  @override
  String get quadrant => '象限';

  @override
  String get category => '类别';

  @override
  String get createCategory => '创建类别';

  @override
  String get dueDate => '截止日期';

  @override
  String get removeDescription => '删除描述';

  @override
  String get removeDescriptionConfirm => '您要删除描述吗？';

  @override
  String get removeDueDate => '删除截止日期';

  @override
  String get removeDueDateConfirm => '您要删除截止日期吗？';

  @override
  String get deleteTask => '删除任务';

  @override
  String get deleteTaskConfirm => '您要删除此任务吗？';

  @override
  String get save => '保存';

  @override
  String get createTask => '创建任务';

  @override
  String get delete => '删除';

  @override
  String get remove => '移除';

  @override
  String get cancel => '取消';

  @override
  String dueDateLabel(String date) {
    return '截止日期：$date';
  }

  @override
  String get completedTasks => '已完成的任务';

  @override
  String get loadingError => '加载错误';

  @override
  String get noCompletedTasks => '没有已完成的任务';

  @override
  String completedOn(String date) {
    return '完成于 $date';
  }

  @override
  String get categories => '类别';

  @override
  String get categoryManagement => '类别管理';

  @override
  String get emoji => '表情符号';

  @override
  String get categoryName => '类别名称';

  @override
  String get add => '添加';

  @override
  String get close => '关闭';

  @override
  String get deleteCategory => '删除类别';

  @override
  String deleteCategoryConfirm(String name) {
    return '删除\"$name\"？';
  }

  @override
  String get deleteCategoryWarning => '相关任务将失去其类别。';

  @override
  String get importFromGoogleTasks => '从 Google Tasks 导入';

  @override
  String get loadingGoogleTasks => '正在加载 Google 任务...';

  @override
  String get unknownError => '未知错误';

  @override
  String get retry => '重试';

  @override
  String get noGoogleTasksFound => '在 Google Tasks 中未找到任务。';

  @override
  String continueWithSelected(int count) {
    return '继续（$count）';
  }

  @override
  String get selectAll => '全选';

  @override
  String get deselectAll => '取消全选';

  @override
  String assignQuadrant(int assigned, int total) {
    return '分配象限（$assigned/$total）';
  }

  @override
  String get quadrantAssigned => '象限已分配 ✓ — 点击另一个以更改';

  @override
  String get dragOrTapQuadrant => '拖动或点击一个象限';

  @override
  String get previous => '上一步';

  @override
  String get skip => '跳过';

  @override
  String get importTasks => '导入任务';

  @override
  String get widgetAppearance => '小部件外观';

  @override
  String get theme => '主题';

  @override
  String get systemTheme => '系统';

  @override
  String get lightTheme => '浅色';

  @override
  String get darkTheme => '深色';

  @override
  String get background => '背景';

  @override
  String transparency(int percent) {
    return '透明度：$percent%';
  }

  @override
  String get textSize => '文字大小';

  @override
  String get small => '小';

  @override
  String get medium => '中';

  @override
  String get large => '大';

  @override
  String get textColor => '文字颜色';

  @override
  String get white => '白色';

  @override
  String get black => '黑色';

  @override
  String get quadrants => '象限';

  @override
  String get widgetUpdated => '小部件已更新。';

  @override
  String get colorRed => '红色';

  @override
  String get colorOrange => '橙色';

  @override
  String get colorYellow => '黄色';

  @override
  String get colorGreen => '绿色';

  @override
  String get colorBlue => '蓝色';

  @override
  String get colorIndigo => '靛蓝色';

  @override
  String get colorPurple => '紫色';

  @override
  String get colorPink => '粉红色';

  @override
  String get colorBrown => '棕色';

  @override
  String get colorGray => '灰色';

  @override
  String get colorTeal => '青色';

  @override
  String get colorCyan => '蓝绿色';

  @override
  String get colorLime => '青柠色';

  @override
  String get colorAmber => '琥珀色';

  @override
  String get colorDeepOrange => '深橙色';

  @override
  String get notificationChannelName => '优先任务';

  @override
  String get notificationChannelDescription => '显示艾森豪威尔矩阵中的优先任务';

  @override
  String get createNewTask => '创建新任务';

  @override
  String taskCount(int count) {
    return '$count 个任务';
  }

  @override
  String get persistentNotification => '持久通知';

  @override
  String get persistentNotificationDescription => '在通知栏中显示优先任务';

  @override
  String get language => '语言';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageItalian => '意大利语';

  @override
  String get languageSpanish => '西班牙语';

  @override
  String get languageFrench => '法语';

  @override
  String get languageGerman => '德语';

  @override
  String get languageChinese => '中文';

  @override
  String get languagePortuguese => '葡萄牙语';

  @override
  String get languageRussian => '俄语';

  @override
  String get languageJapanese => '日语';

  @override
  String get languageArabic => '阿拉伯语';

  @override
  String get onboardingWelcomeTitle => '欢迎使用艾森豪威尔矩阵';

  @override
  String get onboardingWelcomeSubtitle => '优先处理任务的终极工具';

  @override
  String get onboardingWelcomeDescription =>
      '艾森豪威尔矩阵帮助您按紧急程度和重要程度组织任务，让您专注于真正重要的事情。';

  @override
  String get onboardingGetStarted => '开始使用';

  @override
  String get onboardingNotUrgent => '不紧急';

  @override
  String get onboardingNotImportant => '不重要';

  @override
  String get onboardingQ1Description => '立即执行';

  @override
  String get onboardingQ2Description => '计划';

  @override
  String get onboardingQ3Description => '委托';

  @override
  String get onboardingQ4Description => '删除';

  @override
  String get onboardingFeaturesTitle => '强大的功能';

  @override
  String get onboardingFeatureCategories => '使用类别组织';

  @override
  String get onboardingFeatureCategoriesDesc => '创建自定义类别，按项目或上下文对任务进行分组';

  @override
  String get onboardingFeatureNotifications => '常驻通知';

  @override
  String get onboardingFeatureNotificationsDesc => '从通知栏查看您的优先任务';

  @override
  String get onboardingFeatureWidget => '主屏幕小部件';

  @override
  String get onboardingFeatureWidgetDesc => '无需打开应用程序即可一目了然地查看重要任务';

  @override
  String get onboardingFeatureSync => '云同步';

  @override
  String get onboardingFeatureSyncDesc => '您的任务会自动在所有设备上同步';

  @override
  String get onboardingContinue => '继续';

  @override
  String get onboardingSignInTitle => '登录以继续';

  @override
  String get onboardingSignInDescription => '使用您的 Google 帐户登录以同步任务并从任何地方访问它们';

  @override
  String get onboardingSignInSuccess => '登录成功！';

  @override
  String get onboardingCategoriesTitle => '创建您的类别';

  @override
  String get onboardingCategoriesDescription => '类别可帮助您按项目、上下文或您喜欢的任何方式组织任务';

  @override
  String get onboardingNoCategoriesYet => '还没有类别。创建您的第一个！';

  @override
  String get onboardingFinish => '完成';
}
