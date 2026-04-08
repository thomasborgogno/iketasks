import 'dart:convert';
import 'dart:ui';

enum WidgetTextSize { small, medium, large }

enum WidgetTextColor { white, black }

class WidgetAppearanceSettings {
  const WidgetAppearanceSettings({
    required this.bgColorValue,
    required this.bgAlpha,
    required this.textSize,
    required this.visibleQuadrants,
    this.textColor = WidgetTextColor.white,
  });

  /// The RGB portion of the background color (alpha is controlled by [bgAlpha]).
  final int bgColorValue;

  /// 0–255 opacity of the background (128 = ~50%, 255 = fully opaque).
  final int bgAlpha;

  final WidgetTextSize textSize;

  /// Subset of {'q1','q2','q3','q4'} to display in the widget.
  final Set<String> visibleQuadrants;

  /// Whether task text should be black (for light backgrounds) or white (for dark).
  final WidgetTextColor textColor;

  factory WidgetAppearanceSettings.defaults() => const WidgetAppearanceSettings(
    bgColorValue: 0x1C1B1F,
    bgAlpha: 255,
    textSize: WidgetTextSize.medium,
    visibleQuadrants: {'q1', 'q2', 'q3'},
    textColor: WidgetTextColor.white,
  );

  /// The final ARGB color combining [bgColorValue] and [bgAlpha].
  int get bgArgb => (bgAlpha << 24) | (bgColorValue & 0x00FFFFFF);

  Color get bgColor => Color(bgArgb);

  WidgetAppearanceSettings copyWith({
    int? bgColorValue,
    int? bgAlpha,
    WidgetTextSize? textSize,
    Set<String>? visibleQuadrants,
    WidgetTextColor? textColor,
  }) => WidgetAppearanceSettings(
    bgColorValue: bgColorValue ?? this.bgColorValue,
    bgAlpha: bgAlpha ?? this.bgAlpha,
    textSize: textSize ?? this.textSize,
    visibleQuadrants: visibleQuadrants ?? this.visibleQuadrants,
    textColor: textColor ?? this.textColor,
  );

  Map<String, dynamic> toJson() => {
    'bg_color': bgColorValue.toRadixString(16).padLeft(6, '0'),
    'bg_alpha': bgAlpha,
    'text_size': textSize.name,
    'visible_quadrants': visibleQuadrants.toList(),
    'text_color': textColor.name,
  };

  factory WidgetAppearanceSettings.fromJson(Map<String, dynamic> json) {
    int bgColorValue;
    try {
      bgColorValue = int.parse(
        (json['bg_color'] as String?) ?? '1c1b1f',
        radix: 16,
      );
    } catch (_) {
      bgColorValue = 0x1C1B1F;
    }

    final bgAlpha = (json['bg_alpha'] as int?) ?? 255;

    WidgetTextSize textSize;
    switch (json['text_size'] as String?) {
      case 'small':
        textSize = WidgetTextSize.small;
      case 'large':
        textSize = WidgetTextSize.large;
      default:
        textSize = WidgetTextSize.medium;
    }

    final rawQuadrants = json['visible_quadrants'];
    Set<String> visibleQuadrants;
    if (rawQuadrants is List) {
      visibleQuadrants = rawQuadrants.whereType<String>().toSet();
    } else {
      visibleQuadrants = {'q1', 'q2', 'q3'};
    }

    final textColor = (json['text_color'] as String?) == 'black'
        ? WidgetTextColor.black
        : WidgetTextColor.white;

    return WidgetAppearanceSettings(
      bgColorValue: bgColorValue,
      bgAlpha: bgAlpha,
      textSize: textSize,
      visibleQuadrants: visibleQuadrants,
      textColor: textColor,
    );
  }

  factory WidgetAppearanceSettings.fromJsonString(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return WidgetAppearanceSettings.fromJson(map);
    } catch (_) {
      return WidgetAppearanceSettings.defaults();
    }
  }

  String toJsonString() => jsonEncode(toJson());
}
