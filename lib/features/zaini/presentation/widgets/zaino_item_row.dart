import '../../domain/zaino_item.dart';

/// A row in the incomplete-items list: either a category header or an item.
sealed class ZainoRow {
  const ZainoRow();
}

class ZainoHeaderRow extends ZainoRow {
  const ZainoHeaderRow(this.category);
  final String category;
}

class ZainoItemRow extends ZainoRow {
  const ZainoItemRow(
    this.item, {
    this.isFirstInGroup = false,
    this.isLastInGroup = false,
  });
  final ZainoItem item;
  final bool isFirstInGroup;
  final bool isLastInGroup;
}

/// Flattens items grouped by category into a single row list — a header
/// followed by its items — ready for [ZainoAnimatedItemsSliver]/
/// SliverAnimatedList to render. A category in [collapsedCategories] (keyed
/// by its raw, possibly-empty name — see [ZainoHeaderRow.category]) still
/// gets its header row, but its item rows are omitted.
List<ZainoRow> buildZainoRowList(
  List<String> orderedKeys,
  Map<String, List<ZainoItem>> byCategory, {
  Set<String> collapsedCategories = const {},
}) {
  final hasNamedCategory = orderedKeys.any((k) => k.isNotEmpty);
  final rows = <ZainoRow>[];
  for (final cat in orderedKeys) {
    final items = byCategory[cat] ?? const [];
    if (items.isEmpty) continue;
    final showHeader = cat.isNotEmpty || hasNamedCategory;
    if (showHeader) rows.add(ZainoHeaderRow(cat));
    if (collapsedCategories.contains(cat)) continue;
    for (var i = 0; i < items.length; i++) {
      rows.add(
        ZainoItemRow(
          items[i],
          isFirstInGroup: !showHeader && i == 0,
          isLastInGroup: i == items.length - 1,
        ),
      );
    }
  }
  return rows;
}
