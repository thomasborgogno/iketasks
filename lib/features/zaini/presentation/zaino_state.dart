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
  List<Object?> get props => [status, zaini, itemCounts, errorMessage, isSyncing];
}

class ZainoDetailState extends Equatable {
  const ZainoDetailState({
    this.status = ZainoStatus.initial,
    this.items = const [],
    this.tags = const [],
    this.errorMessage,
    this.activeTagFilter = const [],
  });

  final ZainoStatus status;
  final List<ZainoItem> items;
  final List<ZainoTag> tags;
  final String? errorMessage;
  final List<String> activeTagFilter;

  ZainoDetailState copyWith({
    ZainoStatus? status,
    List<ZainoItem>? items,
    List<ZainoTag>? tags,
    String? errorMessage,
    List<String>? activeTagFilter,
  }) {
    return ZainoDetailState(
      status: status ?? this.status,
      items: items ?? this.items,
      tags: tags ?? this.tags,
      errorMessage: errorMessage,
      activeTagFilter: activeTagFilter ?? this.activeTagFilter,
    );
  }

  List<ZainoItem> get filteredItems {
    if (activeTagFilter.isEmpty) return items;
    return items
        .where((item) => item.tags.any((t) => activeTagFilter.contains(t)))
        .toList();
  }

  /// Items grouped by category name. Items without a category are in the '' group.
  Map<String, List<ZainoItem>> get itemsByCategory {
    final map = <String, List<ZainoItem>>{};
    for (final item in filteredItems) {
      final key = item.categoryName ?? '';
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  @override
  List<Object?> get props => [status, items, tags, errorMessage, activeTagFilter];
}
