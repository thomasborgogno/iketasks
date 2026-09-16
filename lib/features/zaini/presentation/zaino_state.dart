import 'package:equatable/equatable.dart';

import '../domain/zaino.dart';
import '../domain/zaino_item.dart';
import '../domain/zaino_tag.dart';

enum ZainoStatus { initial, loading, ready, error }

class ZainoState extends Equatable {
  const ZainoState({
    this.status = ZainoStatus.initial,
    this.zaini = const [],
    this.itemCounts = const {},
    this.errorMessage,
    this.isSyncing = false,
  });

  final ZainoStatus status;
  final List<Zaino> zaini;

  /// Map from zaino id → total item count.
  final Map<String, int> itemCounts;
  final String? errorMessage;
  final bool isSyncing;

  ZainoState copyWith({
    ZainoStatus? status,
    List<Zaino>? zaini,
    Map<String, int>? itemCounts,
    String? errorMessage,
    bool? isSyncing,
  }) {
    return ZainoState(
      status: status ?? this.status,
      zaini: zaini ?? this.zaini,
      itemCounts: itemCounts ?? this.itemCounts,
      errorMessage: errorMessage,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  List<Object?> get props => [
    status,
    zaini,
    itemCounts,
    errorMessage,
    isSyncing,
  ];
}

class ZainoDetailState extends Equatable {
  const ZainoDetailState({
    this.status = ZainoStatus.initial,
    this.items = const [],
    this.tags = const [],
    this.errorMessage,
    this.activeTagFilter = const [],
    this.excludedTagFilter = const [],
    this.categoryOrder = const [],
  });

  final ZainoStatus status;
  final List<ZainoItem> items;
  final List<ZainoTag> tags;
  final String? errorMessage;
  final List<String> activeTagFilter;
  final List<String> excludedTagFilter;

  /// User-chosen display order of category names (via the up/down carets).
  /// Categories not listed here are appended alphabetically after the ones
  /// that are — see [orderedCategoryNames].
  final List<String> categoryOrder;

  ZainoDetailState copyWith({
    ZainoStatus? status,
    List<ZainoItem>? items,
    List<ZainoTag>? tags,
    String? errorMessage,
    List<String>? activeTagFilter,
    List<String>? excludedTagFilter,
    List<String>? categoryOrder,
  }) {
    return ZainoDetailState(
      status: status ?? this.status,
      items: items ?? this.items,
      tags: tags ?? this.tags,
      errorMessage: errorMessage,
      activeTagFilter: activeTagFilter ?? this.activeTagFilter,
      excludedTagFilter: excludedTagFilter ?? this.excludedTagFilter,
      categoryOrder: categoryOrder ?? this.categoryOrder,
    );
  }

  /// True when no tags are selected, or every existing tag is selected —
  /// both cases mean "no filtering", so all items should be shown.
  bool get _isFilterEffectivelyOff {
    if (activeTagFilter.isEmpty) return true;
    if (tags.isEmpty) return true;
    return tags.every((t) => activeTagFilter.contains(t.name));
  }

  List<ZainoItem> get filteredItems {
    var result = _isFilterEffectivelyOff
        ? items
        : items
              .where((item) => item.tags.any((t) => activeTagFilter.contains(t)))
              .toList();
    if (excludedTagFilter.isNotEmpty) {
      result = result
          .where((item) => !item.tags.any((t) => excludedTagFilter.contains(t)))
          .toList();
    }
    return result;
  }

  /// Incomplete items grouped by category name. Items without a category are
  /// in the '' group. Completed items are excluded — see [completedItems].
  Map<String, List<ZainoItem>> get itemsByCategory {
    final map = <String, List<ZainoItem>>{};
    for (final item in filteredItems) {
      if (item.completed) continue;
      final key = item.categoryName ?? '';
      map.putIfAbsent(key, () => []).add(item);
    }
    for (final list in map.values) {
      list.sort(_byTitle);
    }
    return map;
  }

  /// Completed items across all categories, shown separately at the bottom
  /// of the page instead of inline within each category.
  List<ZainoItem> get completedItems {
    return filteredItems.where((i) => i.completed).toList()..sort(_byTitle);
  }

  @override
  List<Object?> get props => [
    status,
    items,
    tags,
    errorMessage,
    activeTagFilter,
    excludedTagFilter,
    categoryOrder,
  ];
}

int _byTitle(ZainoItem a, ZainoItem b) =>
    a.title.toLowerCase().compareTo(b.title.toLowerCase());

/// Orders [present] category names: those listed in [savedOrder] come first
/// (in that order), followed by the rest sorted alphabetically. Lets the
/// user reorder categories via the up/down carets while newly-seen
/// categories still show up in a sensible place.
List<String> orderedCategoryNames(
  List<String> present,
  List<String> savedOrder,
) {
  final presentSet = present.toSet();
  final ordered = [
    for (final c in savedOrder)
      if (presentSet.contains(c)) c,
  ];
  final remaining = present.where((c) => !ordered.contains(c)).toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return [...ordered, ...remaining];
}
