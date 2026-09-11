import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/presentation/auth_cubit.dart';
import '../data/zaino_google_tasks_service.dart';
import '../data/zaino_repository.dart';
import '../domain/zaino.dart';
import 'zaini_search_delegate.dart';
import 'zaino_cubit.dart';
import 'zaino_detail_page.dart';
import 'zaino_state.dart';
import 'widgets/zaino_form_sheet.dart';

class ZainiListPage extends StatelessWidget {
  const ZainiListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZainoCubit, ZainoState>(
      builder: (context, state) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: const Text('Zaini'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'Cerca zaino',
                    onPressed: () async {
                      final zaino = await showSearch<Zaino?>(
                        context: context,
                        delegate: ZainiSearchDelegate(
                          zaini: state.zaini,
                          onZainoTap: (z) => _openDetail(context, z),
                        ),
                      );
                      if (zaino != null && context.mounted) {
                        _openDetail(context, zaino);
                      }
                    },
                  ),
                  if (state.isSyncing)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.sync),
                      tooltip: 'Sincronizza con Google Tasks',
                      onPressed: () =>
                          context.read<ZainoCubit>().syncFromGoogleTasks(),
                    ),
                ],
              ),
              if (state.status == ZainoStatus.loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.zaini.isEmpty)
                SliverFillRemaining(
                  child: _EmptyState(onCreate: () => _showCreateSheet(context)),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  sliver: SliverList.separated(
                    itemCount: state.zaini.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final zaino = state.zaini[index];
                      return _ZainoCard(
                        zaino: zaino,
                        itemCount: state.itemCounts[zaino.id],
                        onTap: () => _openDetail(context, zaino),
                        onEdit: () => _showEditSheet(context, zaino),
                        onDelete: () => _confirmDelete(context, zaino),
                      );
                    },
                  ),
                ),
            ],
          ),
          floatingActionButton:
              state.status == ZainoStatus.loading || state.zaini.isEmpty
              ? null
              : FloatingActionButton(
                  onPressed: () => _showCreateSheet(context),
                  child: const Icon(Icons.add),
                ),
        );
      },
    );
  }

  Future<void> _showCreateSheet(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ZainoFormSheet(),
    );
    if (result == null || !context.mounted) return;
    await context.read<ZainoCubit>().createZaino(
      name: result['name'] as String,
      emoji: result['emoji'] as String?,
    );
  }

  Future<void> _showEditSheet(BuildContext context, Zaino zaino) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          ZainoFormSheet(initialName: zaino.name, initialEmoji: zaino.emoji),
    );
    if (result == null || !context.mounted) return;
    await context.read<ZainoCubit>().updateZaino(
      zaino,
      name: result['name'] as String,
      emoji: result['emoji'] as String?,
      clearEmoji: result['emoji'] == null,
    );
  }

  Future<void> _confirmDelete(BuildContext context, Zaino zaino) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina zaino'),
        content: Text(
          'Elimina "${zaino.name}"?\nAnche la lista Google Tasks corrispondente verrà eliminata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ZainoCubit>().deleteZaino(zaino);
    }
  }

  Future<void> _openDetail(BuildContext context, Zaino zaino) async {
    final uid = context.read<AuthCubit>().state.user?.uid;
    if (uid == null) return;
    final zainoCubit = context.read<ZainoCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (ctx) => ZainoDetailCubit(
            ctx.read<ZainoRepository>(),
            ctx.read<ZainoGoogleTasksService>(),
            zaino,
          )..bindUser(uid),
          child: ZainoDetailPage(zaino: zaino),
        ),
      ),
    );
    await zainoCubit.refreshItemCounts();
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _ZainoCard extends StatelessWidget {
  const _ZainoCard({
    required this.zaino,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.itemCount,
  });

  final Zaino zaino;
  final int? itemCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emoji = zaino.emoji;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (emoji != null && emoji.isNotEmpty)
                Text(emoji, style: const TextStyle(fontSize: 32))
              else
                Icon(
                  Icons.backpack_outlined,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(zaino.name, style: theme.textTheme.titleMedium),
                    if (itemCount != null)
                      Text(
                        '$itemCount element${itemCount == 1 ? 'o' : 'i'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<_CardAction>(
                onSelected: (action) {
                  if (action == _CardAction.edit) onEdit();
                  if (action == _CardAction.delete) onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: _CardAction.edit,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Modifica'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: _CardAction.delete,
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Elimina'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _CardAction { edit, delete }

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.backpack_outlined,
              size: 64,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Nessuno zaino',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea uno zaino o sincronizza con Google Tasks\n(liste che iniziano con "#")',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Crea zaino'),
            ),
          ],
        ),
      ),
    );
  }
}
