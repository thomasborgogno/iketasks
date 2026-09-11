import 'package:flutter_test/flutter_test.dart';
import 'package:iketasks/features/zaini/domain/zaino_item.dart';
import 'package:iketasks/features/zaini/domain/zaino_tag.dart';
import 'package:iketasks/features/zaini/presentation/zaino_state.dart';

ZainoItem _item(
  String id, {
  String? categoryName,
  List<String> tags = const [],
  bool completed = false,
  int order = 0,
}) {
  final now = DateTime(2026, 1, 1);
  return ZainoItem(
    id: id,
    zainoId: 'z1',
    title: id,
    completed: completed,
    order: order,
    categoryName: categoryName,
    tags: tags,
    createdAt: now,
    updatedAt: now,
  );
}

ZainoTag _tag(String name) {
  return ZainoTag(
    id: name,
    zainoId: 'z1',
    name: name,
    order: 0,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('ZainoDetailState.filteredItems', () {
    final untagged = _item('untagged');
    final tagged = _item('tagged', tags: ['a']);
    final items = [untagged, tagged];
    final tags = [_tag('a'), _tag('b')];

    test('shows everything when no filter is active', () {
      final state = ZainoDetailState(items: items, tags: tags);
      expect(state.filteredItems, items);
    });

    test('shows only items matching selected tags', () {
      final state = ZainoDetailState(
        items: items,
        tags: tags,
        activeTagFilter: const ['a'],
      );
      expect(state.filteredItems, [tagged]);
    });

    test('treats "all tags selected" the same as no filter', () {
      final state = ZainoDetailState(
        items: items,
        tags: tags,
        activeTagFilter: const ['a', 'b'],
      );
      expect(state.filteredItems, items);
    });
  });

  group('ZainoDetailState.itemsByCategory', () {
    test('excludes completed items — they live in completedItems instead', () {
      final done = _item('done', categoryName: 'Cat', completed: true, order: 0);
      final todo = _item('todo', categoryName: 'Cat', completed: false, order: 1);
      final state = ZainoDetailState(items: [done, todo]);

      expect(state.itemsByCategory['Cat'], [todo]);
    });

    test('groups uncategorized items under the empty-string key', () {
      final a = _item('a', categoryName: 'Cat');
      final b = _item('b');
      final state = ZainoDetailState(items: [a, b]);

      expect(state.itemsByCategory['Cat'], [a]);
      expect(state.itemsByCategory[''], [b]);
    });
  });

  group('ZainoDetailState.completedItems', () {
    test('collects completed items across categories, ordered by order', () {
      final doneB = _item('doneB', categoryName: 'B', completed: true, order: 1);
      final doneA = _item('doneA', categoryName: 'A', completed: true, order: 0);
      final todo = _item('todo', categoryName: 'A', completed: false, order: 2);
      final state = ZainoDetailState(items: [doneB, doneA, todo]);

      expect(state.completedItems, [doneA, doneB]);
    });
  });
}
