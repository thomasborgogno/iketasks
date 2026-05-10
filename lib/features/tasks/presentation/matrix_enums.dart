import 'package:iketasks/features/tasks/domain/eisenhower_quadrant.dart';

enum MatrixLayoutMode { grid, stacked }

enum TaskInputMode { quadrantOnly, priorityOnly, both }

const List<List<EisenhowerQuadrant>> matrixQuadrantRows = [
  [EisenhowerQuadrant.importantUrgent, EisenhowerQuadrant.importantNotUrgent],
  [
    EisenhowerQuadrant.notImportantUrgent,
    EisenhowerQuadrant.notImportantNotUrgent,
  ],
];
