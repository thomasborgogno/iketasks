import 'package:flutter/material.dart';

import '../../../core/utils/fuzzy_search.dart';
import '../domain/zaino.dart';
import '../domain/zaino_item.dart';

class ZainiSearchDelegate extends SearchDelegate<Zaino?> {
  ZainiSearchDelegate({required this.zaini, required this.onZainoTap});

  final List<Zaino> zaini;
  final ValueChanged<Zaino> onZainoTap;

  @override
  String get searchFieldLabel => 'Cerca zaino…';

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final filtered = FuzzySearch.filter(
      query,
      zaini,
      (z) => [z.name],
    );
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'Nessun risultato',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final zaino = filtered[i];
        final emoji = zaino.emoji;
        return ListTile(
          leading: emoji != null && emoji.isNotEmpty
              ? Text(emoji, style: const TextStyle(fontSize: 24))
              : const Icon(Icons.backpack_outlined),
          title: Text(zaino.name),
          onTap: () {
            close(context, zaino);
            onZainoTap(zaino);
          },
        );
      },
    );
  }
}

class ZainoItemSearchDelegate extends SearchDelegate<ZainoItem?> {
  ZainoItemSearchDelegate({
    required this.items,
    required this.onItemTap,
  });

  final List<ZainoItem> items;
  final ValueChanged<ZainoItem> onItemTap;

  @override
  String get searchFieldLabel => 'Cerca elemento…';

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final filtered = FuzzySearch.filter(
      query,
      items,
      (i) => [i.title, i.categoryName, ...i.tags],
    );
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'Nessun risultato',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, idx) {
        final item = filtered[idx];
        return ListTile(
          leading: Checkbox(
            value: item.completed,
            onChanged: null,
          ),
          title: Text(
            item.title,
            style: item.completed
                ? TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )
                : null,
          ),
          subtitle: item.categoryName != null
              ? Text(item.categoryName!, style: const TextStyle(fontSize: 12))
              : null,
          onTap: () {
            close(context, item);
            onItemTap(item);
          },
        );
      },
    );
  }
}
