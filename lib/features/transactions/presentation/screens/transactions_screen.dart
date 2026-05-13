import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/core/utils/responsive.dart';
import 'package:btg_funds_app/features/transactions/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/transactions/presentation/widgets/active_filters_chip.dart';
import 'package:btg_funds_app/features/transactions/presentation/widgets/filter_bottom_sheet.dart';
import 'package:btg_funds_app/features/transactions/presentation/widgets/filter_trigger_chip.dart';
import 'package:btg_funds_app/features/transactions/presentation/widgets/transaction_card.dart';
import 'package:btg_funds_app/features/transactions/presentation/widgets/transaction_card_skeleton.dart';
import 'package:btg_funds_app/shared/widgets/app_empty_view.dart';
import 'package:btg_funds_app/shared/widgets/app_error_view.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txsAsync = ref.watch(transactionsNotifierProvider);
    final notifier = ref.watch(transactionsNotifierProvider.notifier);
    final currentFilter = notifier.currentFilter;

    Future<void> openFilters() async {
      final result = await showFilterBottomSheet(
        context,
        current: currentFilter,
      );
      if (result == null) return;
      await notifier.applyFilter(result);
    }

    return Scaffold(
      key: const ValueKey('transactions-screen'),
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          IconButton(
            tooltip: 'Filtrar',
            icon: const Icon(Icons.filter_list),
            onPressed: openFilters,
          ),
        ],
      ),
      body: centeredOnDesktop(
        context,
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilterTriggerChip(onTap: openFilters),
              ),
            ),
            ActiveFiltersChips(filter: currentFilter),
            Expanded(
              child: txsAsync.when(
                loading: () => ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    screenPadding(context).left,
                    AppSpacing.sm,
                    screenPadding(context).right,
                    AppSpacing.lg,
                  ),
                  itemCount: 6,
                  itemBuilder: (ctx, _) => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: TransactionCardSkeleton(),
                  ),
                ),
                error: (e, _) => AppErrorView(
                  message: e.toString(),
                  onRetry: notifier.refresh,
                ),
                data: (txs) {
                  if (txs.isEmpty) {
                    return AppEmptyView(
                      icon: Icons.receipt_long_outlined,
                      title: currentFilter.isEmpty
                          ? 'Aún no tienes transacciones'
                          : 'No hay transacciones con esos filtros',
                      subtitle: currentFilter.isEmpty
                          ? 'Cuando te suscribas a un fondo, lo verás aquí.'
                          : 'Ajusta o limpia los filtros.',
                      actionLabel:
                          currentFilter.isEmpty ? 'Explorar fondos' : null,
                      onAction: currentFilter.isEmpty
                          ? () => context.go('/funds')
                          : null,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: notifier.refresh,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        screenPadding(context).left,
                        AppSpacing.sm,
                        screenPadding(context).right,
                        AppSpacing.lg,
                      ),
                      itemCount: txs.length,
                      itemBuilder: (ctx, index) {
                        final card = Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: TransactionCard(transaction: txs[index]),
                        );
                        // Stagger entrance solo para los primeros 8 items:
                        // a partir del 9 aparecen inmediatamente para no
                        // ralentizar listas largas (skill §12.4).
                        if (index >= 8) return card;
                        return TweenAnimationBuilder<double>(
                          key: ValueKey('tx-stagger-${txs[index].id}'),
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 250 + index * 50),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) => Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 16 * (1 - value)),
                              child: child,
                            ),
                          ),
                          child: card,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
