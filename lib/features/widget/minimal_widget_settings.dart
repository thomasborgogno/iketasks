import 'dart:convert';

enum MinimalWidgetTextColor { white, black }

enum MinimalWidgetTextSize { small, medium, large }

enum MinimalWidgetTextAlignment { left, center, right }

class MinimalWidgetSettings {
  const MinimalWidgetSettings({
    required this.taskCount,
    required this.textColor,
    required this.textSize,
    required this.fallbackToNextQuadrants,
    this.textAlignment = MinimalWidgetTextAlignment.left,
  });

  /// Number of tasks from Priority quadrant to show (1-5)
  final int taskCount;

  /// Text color (white or black)
  final MinimalWidgetTextColor textColor;

  /// Text size
  final MinimalWidgetTextSize textSize;

  /// If true, take tasks from subsequent quadrants when Priority is empty
  final bool fallbackToNextQuadrants;

  /// Text alignment within the widget
  final MinimalWidgetTextAlignment textAlignment;

  factory MinimalWidgetSettings.defaults() => const MinimalWidgetSettings(
    taskCount: 3,
    textColor: MinimalWidgetTextColor.white,
    textSize: MinimalWidgetTextSize.medium,
    fallbackToNextQuadrants: false,
    textAlignment: MinimalWidgetTextAlignment.left,
  );

  MinimalWidgetSettings copyWith({
    int? taskCount,
    MinimalWidgetTextColor? textColor,
    MinimalWidgetTextSize? textSize,
    bool? fallbackToNextQuadrants,
    MinimalWidgetTextAlignment? textAlignment,
  }) => MinimalWidgetSettings(
    taskCount: taskCount ?? this.taskCount,
    textColor: textColor ?? this.textColor,
    textSize: textSize ?? this.textSize,
    fallbackToNextQuadrants:
        fallbackToNextQuadrants ?? this.fallbackToNextQuadrants,
    textAlignment: textAlignment ?? this.textAlignment,
  );

  Map<String, dynamic> toJson() => {
    'task_count': taskCount,
    'text_color': textColor.name,
    'text_size': textSize.name,
    'fallback_to_next_quadrants': fallbackToNextQuadrants,
    'text_alignment': textAlignment.name,
  };

  factory MinimalWidgetSettings.fromJson(Map<String, dynamic> json) {
    final taskCount = (json['task_count'] as int?) ?? 3;

    final textColor = (json['text_color'] as String?) == 'black'
        ? MinimalWidgetTextColor.black
        : MinimalWidgetTextColor.white;

    MinimalWidgetTextSize textSize;
    switch (json['text_size'] as String?) {
      case 'small':
        textSize = MinimalWidgetTextSize.small;
      case 'large':
        textSize = MinimalWidgetTextSize.large;
      default:
        textSize = MinimalWidgetTextSize.medium;
    }

    final fallbackToNextQuadrants =
        (json['fallback_to_next_quadrants'] as bool?) ?? false;

    MinimalWidgetTextAlignment textAlignment;
    switch (json['text_alignment'] as String?) {
      case 'center':
        textAlignment = MinimalWidgetTextAlignment.center;
      case 'right':
        textAlignment = MinimalWidgetTextAlignment.right;
      default:
        textAlignment = MinimalWidgetTextAlignment.left;
    }

    return MinimalWidgetSettings(
      taskCount: taskCount.clamp(1, 5),
      textColor: textColor,
      textSize: textSize,
      fallbackToNextQuadrants: fallbackToNextQuadrants,
      textAlignment: textAlignment,
    );
  }

  factory MinimalWidgetSettings.fromJsonString(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return MinimalWidgetSettings.fromJson(map);
    } catch (_) {
      return MinimalWidgetSettings.defaults();
    }
  }

  String toJsonString() => jsonEncode(toJson());
}
