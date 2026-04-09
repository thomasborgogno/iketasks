// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get authError => '認証エラー';

  @override
  String get signInSubtitle => '緊急性と重要性でタスクを整理します。';

  @override
  String get signInWithGoogle => 'Googleでログイン';

  @override
  String get googleUser => 'Googleユーザー';

  @override
  String get settings => '設定';

  @override
  String get profileAndSettings => 'プロフィールと設定';

  @override
  String get signOut => 'ログアウト';

  @override
  String get quadrantImportantUrgent => '重要、緊急';

  @override
  String get quadrantImportantNotUrgent => '重要、緊急でない';

  @override
  String get quadrantNotImportantUrgent => '重要でない、緊急';

  @override
  String get quadrantNotImportantNotUrgent => '重要でない、緊急でない';

  @override
  String get quadrantNamePriority => '優先';

  @override
  String get quadrantNamePlan => '計画';

  @override
  String get quadrantNameDelegate => '委任';

  @override
  String get quadrantNameEliminate => '削除';

  @override
  String get yourEisenhowerMatrix => 'アイゼンハワーマトリックス';

  @override
  String greeting(String name) {
    return 'こんにちは、$name！';
  }

  @override
  String get columnView => '列表示';

  @override
  String get gridView => 'グリッド表示';

  @override
  String get empty => '空';

  @override
  String get newTask => '新しいタスク';

  @override
  String get editTask => 'タスクを編集';

  @override
  String get taskTitle => 'タイトル';

  @override
  String get taskDescription => '説明';

  @override
  String get priority => '優先度';

  @override
  String get important => '重要';

  @override
  String get urgent => '緊急';

  @override
  String get quadrant => '象限';

  @override
  String get category => 'カテゴリ';

  @override
  String get createCategory => 'カテゴリを作成';

  @override
  String get dueDate => '期限';

  @override
  String get removeDescription => '説明を削除';

  @override
  String get removeDescriptionConfirm => '説明を削除しますか？';

  @override
  String get removeDueDate => '期限を削除';

  @override
  String get removeDueDateConfirm => '期限を削除しますか？';

  @override
  String get deleteTask => 'タスクを削除';

  @override
  String get deleteTaskConfirm => 'このタスクを削除しますか？';

  @override
  String get save => '保存';

  @override
  String get createTask => 'タスクを作成';

  @override
  String get delete => '削除';

  @override
  String get remove => '削除';

  @override
  String get cancel => 'キャンセル';

  @override
  String dueDateLabel(String date) {
    return '期限：$date';
  }

  @override
  String get completedTasks => '完了したタスク';

  @override
  String get loadingError => '読み込みエラー';

  @override
  String get noCompletedTasks => '完了したタスクはありません';

  @override
  String completedOn(String date) {
    return '$date に完了';
  }

  @override
  String get categories => 'カテゴリ';

  @override
  String get categoryManagement => 'カテゴリ管理';

  @override
  String get emoji => '絵文字';

  @override
  String get categoryName => 'カテゴリ名';

  @override
  String get add => '追加';

  @override
  String get close => '閉じる';

  @override
  String get deleteCategory => 'カテゴリを削除';

  @override
  String deleteCategoryConfirm(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get deleteCategoryWarning => '関連付けられたタスクはカテゴリを失います。';

  @override
  String get importFromGoogleTasks => 'Google Tasksからインポート';

  @override
  String get loadingGoogleTasks => 'Google Tasksを読み込み中...';

  @override
  String get unknownError => '不明なエラー';

  @override
  String get retry => '再試行';

  @override
  String get noGoogleTasksFound => 'Google Tasksにタスクが見つかりませんでした。';

  @override
  String continueWithSelected(int count) {
    return '続ける（$count）';
  }

  @override
  String get selectAll => 'すべて選択';

  @override
  String get deselectAll => 'すべて選択解除';

  @override
  String assignQuadrant(int assigned, int total) {
    return '象限を割り当て（$assigned/$total）';
  }

  @override
  String get quadrantAssigned => '象限が割り当てられました ✓ — 別の象限をタップして変更';

  @override
  String get dragOrTapQuadrant => '象限をドラッグまたはタップ';

  @override
  String get previous => '前へ';

  @override
  String get skip => 'スキップ';

  @override
  String get importTasks => 'タスクをインポート';

  @override
  String get widgetAppearance => 'ウィジェットの外観';

  @override
  String get theme => 'テーマ';

  @override
  String get systemTheme => 'システム';

  @override
  String get lightTheme => 'ライト';

  @override
  String get darkTheme => 'ダーク';

  @override
  String get background => '背景';

  @override
  String transparency(int percent) {
    return '透明度：$percent%';
  }

  @override
  String get textSize => 'テキストサイズ';

  @override
  String get small => '小';

  @override
  String get medium => '中';

  @override
  String get large => '大';

  @override
  String get textColor => 'テキストの色';

  @override
  String get white => '白';

  @override
  String get black => '黒';

  @override
  String get quadrants => '象限';

  @override
  String get widgetUpdated => 'ウィジェットが更新されました。';

  @override
  String get colorRed => '赤';

  @override
  String get colorOrange => 'オレンジ';

  @override
  String get colorYellow => '黄色';

  @override
  String get colorGreen => '緑';

  @override
  String get colorBlue => '青';

  @override
  String get colorIndigo => '藍色';

  @override
  String get colorPurple => '紫';

  @override
  String get colorPink => 'ピンク';

  @override
  String get colorBrown => '茶色';

  @override
  String get colorGray => 'グレー';

  @override
  String get colorTeal => '青緑';

  @override
  String get colorCyan => 'シアン';

  @override
  String get colorLime => 'ライム';

  @override
  String get colorAmber => 'アンバー';

  @override
  String get colorDeepOrange => '深いオレンジ';

  @override
  String get notificationChannelName => '優先タスク';

  @override
  String get notificationChannelDescription => 'アイゼンハワーマトリックスの優先タスクを表示';

  @override
  String get createNewTask => '新しいタスクを作成';

  @override
  String taskCount(int count) {
    return '$count タスク';
  }

  @override
  String get persistentNotification => '永続的な通知';

  @override
  String get persistentNotificationDescription => '通知バーに優先タスクを表示';

  @override
  String get language => '言語';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageItalian => 'イタリア語';

  @override
  String get languageSpanish => 'スペイン語';

  @override
  String get languageFrench => 'フランス語';

  @override
  String get languageGerman => 'ドイツ語';

  @override
  String get languageChinese => '中国語';

  @override
  String get languagePortuguese => 'ポルトガル語';

  @override
  String get languageRussian => 'ロシア語';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageArabic => 'アラビア語';

  @override
  String get onboardingWelcomeTitle => 'アイゼンハワーマトリックスへようこそ';

  @override
  String get onboardingWelcomeSubtitle => 'タスクの優先順位付けに最適なツール';

  @override
  String get onboardingWelcomeDescription =>
      'アイゼンハワーマトリックスは、緊急度と重要度でタスクを整理し、本当に重要なことに集中できるようにします。';

  @override
  String get onboardingGetStarted => '始める';

  @override
  String get onboardingNotUrgent => '緊急でない';

  @override
  String get onboardingNotImportant => '重要でない';

  @override
  String get onboardingQ1Description => '今すぐ実行';

  @override
  String get onboardingQ2Description => 'スケジュール';

  @override
  String get onboardingQ3Description => '委任';

  @override
  String get onboardingQ4Description => '削除';

  @override
  String get onboardingFeaturesTitle => '強力な機能';

  @override
  String get onboardingFeatureCategories => 'カテゴリで整理';

  @override
  String get onboardingFeatureCategoriesDesc =>
      'プロジェクトやコンテキストでタスクをグループ化するカスタムカテゴリを作成';

  @override
  String get onboardingFeatureNotifications => '常時通知';

  @override
  String get onboardingFeatureNotificationsDesc => '通知バーから優先タスクを確認できます';

  @override
  String get onboardingFeatureWidget => 'ホーム画面ウィジェット';

  @override
  String get onboardingFeatureWidgetDesc => 'アプリを開かずに重要なタスクを一目で確認';

  @override
  String get onboardingFeatureSync => 'クラウド同期';

  @override
  String get onboardingFeatureSyncDesc => 'すべてのデバイスでタスクが自動的に同期';

  @override
  String get onboardingContinue => '続ける';

  @override
  String get onboardingSignInTitle => 'サインインして続ける';

  @override
  String get onboardingSignInDescription =>
      'Googleアカウントでサインインして、タスクを同期し、どこからでもアクセス';

  @override
  String get onboardingSignInSuccess => 'サインイン成功！';

  @override
  String get onboardingCategoriesTitle => 'カテゴリを作成';

  @override
  String get onboardingCategoriesDescription =>
      'カテゴリは、プロジェクト、コンテキスト、または好みの方法でタスクを整理するのに役立ちます';

  @override
  String get onboardingNoCategoriesYet => 'まだカテゴリがありません。最初のカテゴリを作成しましょう！';

  @override
  String get onboardingFinish => '完了';
}
