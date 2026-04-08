import 'package:home_widget/home_widget.dart';

import 'widget_appearance_settings.dart';

class WidgetAppearanceService {
  static const _androidProvider = 'EisenhowerGlanceReceiver';
  static const _prefKey = 'widget_appearance';

  WidgetAppearanceSettings _current = WidgetAppearanceSettings.defaults();

  WidgetAppearanceSettings get current => _current;

  Future<void> initialize() async {
    final raw = await HomeWidget.getWidgetData<String>(_prefKey);
    if (raw != null && raw.isNotEmpty) {
      _current = WidgetAppearanceSettings.fromJsonString(raw);
    }
  }

  Future<void> save(WidgetAppearanceSettings settings) async {
    _current = settings;
    await HomeWidget.saveWidgetData<String>(_prefKey, settings.toJsonString());
    await HomeWidget.updateWidget(androidName: _androidProvider);
  }
}
