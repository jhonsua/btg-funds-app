import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/core/utils/responsive.dart';
import 'package:btg_funds_app/features/transactions/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/transactions/presentation/widgets/active_filters_chip.dart';
import 'package:btg_funds_app/features/transactions/presentation/widgets/filter_bottom_sheet.dart';
import 'package:btg_funds_app/features/transactions/presentation/widgets/transaction_card.dart';
import 'package:btg_funds_app/shared/widgets/app_empty_view.dart';
import 'package:btg_funds_app/shared/widgets/app_error_view.dart';
import 'package:btg_funds_app/shared/widgets/app_skeleton.dart';

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
                loading: () => _TransactionsLoadingSkeleton(
                  padding: EdgeInsets.fromLTRB(
                    screenPadding(context).left,
                    AppSpacing.sm,
                    screenPadding(context).right,
                    AppSpacing.lg,
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

/// Skeleton shimmer que imita la estructura del `TransactionCard`
/// (badge + fecha + nombre fondo + monto). Reemplaza el spinner genérico
/// durante el loading inicial (skill §14).
class _TransactionsLoadingSkeleton extends StatelessWidget {
  const _TransactionsLoadingSkeleton({required this.padding});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      child: Column(
        children: List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppSkeleton(width: 80, height: 20, borderRadius: 4),
                      SizedBox(width: AppSpacing.sm),
                      AppSkeleton(width: 100, height: 14),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  AppSkeleton(width: 180, height: 16),
                  SizedBox(height: AppSpacing.xs),
                  AppSkeleton(width: 120, height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
