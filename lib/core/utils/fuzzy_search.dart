/// Fuzzy search utility.
///
/// Matches items where every whitespace-separated term in [query] appears
/// as a substring (case-insensitive) in at least one of the [fields].
/// An empty or blank query matches everything.
class FuzzySearch {
  const FuzzySearch._();

  static bool matches(String query, List<String?> fields) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final terms = q.split(RegExp(r'\s+'));
    for (final term in terms) {
      if (term.isEmpty) continue;
      final found = fields.any(
        (f) => f != null && f.toLowerCase().contains(term),
      );
      if (!found) return false;
    }
    return true;
  }

  /// Returns a score in [0, 1] indicating how well [query] matches [fields].
  /// 1.0 means query is empty or identical match; lower is worse.
  static double score(String query, List<String?> fields) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return 1.0;
    if (!matches(q, fields)) return 0.0;
    // Score: prefer early matches and exact word matches
    double best = 0.0;
    for (final raw in fields) {
      if (raw == null) continue;
      final f = raw.toLowerCase();
      if (f == q) {
        best = 1.0;
        break;
      }
      if (f.startsWith(q)) {
        best = best < 0.9 ? 0.9 : best;
      } else if (f.contains(q)) {
        best = best < 0.7 ? 0.7 : best;
      } else {
        best = best < 0.5 ? 0.5 : best;
      }
    }
    return best;
  }

  static List<T> filter<T>(
    String query,
    List<T> items,
    List<String?> Function(T) fields,
  ) {
    final q = query.trim();
    if (q.isEmpty) return items;
    return items.where((item) => matches(q, fields(item))).toList();
  }
}
