import 'package:shared_preferences/shared_preferences.dart';
import 'package:iketasks/features/tasks/presentation/matrix_enums.dart';

/// Handles SharedPreferences persistence for MatrixPage UI state.
class MatrixPrefsService {
  static const _taskInputModePrefKey = 'task_input_mode';
  static const _selectedCategoryIdsPrefKey = 'selected_category_ids';
  static const _excludedCategoryIdsPrefKey = 'excluded_category_ids';
  static const _layoutModePrefKey = 'layout_mode';

  Future<TaskInputMode> loadTaskInputMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_taskInputModePrefKey);
    return TaskInputMode.values.firstWhere(
      (v) => v.name == raw,
      orElse: () => TaskInputMode.quadrantOnly,
    );
  }

  Future<void> saveTaskInputMode(TaskInputMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_taskInputModePrefKey, mode.name);
  }

  Future<Set<String>> loadSelectedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    return Set<String>.from(
      prefs.getStringList(_selectedCategoryIdsPrefKey) ?? [],
    );
  }

  Future<void> saveSelectedCategories(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_selectedCategoryIdsPrefKey, ids.toList());
  }

  Future<Set<String>> loadExcludedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    return Set<String>.from(
      prefs.getStringList(_excludedCategoryIdsPrefKey) ?? [],
    );
  }

  Future<void> saveExcludedCategories(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_excludedCategoryIdsPrefKey, ids.toList());
  }

  Future<MatrixLayoutMode> loadLayoutMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_layoutModePrefKey);
    return MatrixLayoutMode.values.firstWhere(
      (v) => v.name == raw,
      orElse: () => MatrixLayoutMode.grid,
    );
  }

  Future<void> saveLayoutMode(MatrixLayoutMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_layoutModePrefKey, mode.name);
  }
}
