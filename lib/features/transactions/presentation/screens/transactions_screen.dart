import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/core/utils/responsive.dart';
import 'package:btg_funds_app/features/transactions/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/transactions/presentation/widgets/active_filters_chip.dart';
import 'package:btg_funds_app/features/transactions/presentation/widgets/filter_bottom_sheet.dart';
import 'package:btg_funds_app/features/transactions/presentation/widgets/transaction_card.dart';
import 'package:btg_funds_app/shared/widgets/app_empty_view.dart';
import 'package:btg_funds_app/shared/widgets/app_error_view.dart';
import 'package:btg_funds_app/shared/widgets/app_loading.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txsAsync = ref.watch(transactionsNotifierProvider);
    final notifier = ref.watch(transactionsNotifierProvider.notifier);
    final currentFilter = notifier.currentFilter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          IconButton(
            tooltip: 'Filtrar',
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final result = await showFilterBottomSheet(
                context,
                current: currentFilter,
              );
              if (result == null) return;
              await notifier.applyFilter(result);
            },
          ),
        ],
      ),
      body: centeredOnDesktop(
        context,
        Column(
          children: [
            ActiveFiltersChips(filter: currentFilter),
            Expanded(
              child: txsAsync.when(
                loading: () => const AppLoading(),
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
                      itemBuilder: (ctx, index) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: TransactionCard(transaction: txs[index]),
                      ),
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
