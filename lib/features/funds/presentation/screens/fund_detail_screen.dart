import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/core/theme/app_text_styles.dart';
import 'package:btg_funds_app/core/utils/formatters.dart';
import 'package:btg_funds_app/core/utils/responsive.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund_category.dart';
import 'package:btg_funds_app/features/funds/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/funds/presentation/widgets/fund_category_badge.dart';
import 'package:btg_funds_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/notifiers/subscription_state.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/providers/providers.dart';
import 'package:btg_funds_app/shared/widgets/app_button.dart';
import 'package:btg_funds_app/shared/widgets/app_card.dart';
import 'package:btg_funds_app/shared/widgets/app_error_view.dart';
import 'package:btg_funds_app/shared/widgets/app_loading.dart';
import 'package:btg_funds_app/shared/widgets/money_display.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/widgets/confirm_cancel_dialog.dart';

class FundDetailScreen extends ConsumerWidget {
  const FundDetailScreen({super.key, required this.fundId});

  final String fundId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fundAsync = ref.watch(fundByIdProvider(fundId));
    final subscriptions =
        ref.watch(subscriptionsListNotifierProvider).valueOrNull ??
            const <Subscription>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de fondo')),
      body: centeredOnDesktop(
        context,
        fundAsync.when(
          loading: () => const AppLoading(),
          error: (e, _) => AppErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(fundByIdProvider(fundId)),
          ),
          data: (fund) {
            Subscription? activeSub;
            for (final s in subscriptions) {
              if (s.fundId == fund.id) {
                activeSub = s;
                break;
              }
            }
            return _Body(fund: fund, activeSubscription: activeSub);
          },
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.fund, required this.activeSubscription});

  final Fund fund;
  final Subscription? activeSubscription;

  String _categoryDescription(FundCategory category) => category ==
          FundCategory.fpv
      ? 'Fondo Voluntario de Pensión — orientado a retiro con beneficios fiscales.'
      : 'Fondo de Inversión Colectiva — producto líquido para inversión.';

  Future<void> _onCancel(BuildContext context, WidgetRef ref) async {
    final sub = activeSubscription!;
    final confirmed = await showConfirmCancelDialog(
      context,
      fundName: sub.fundName,
      amount: sub.amount,
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    final ok = await ref
        .read(subscriptionNotifierProvider.notifier)
        .cancel(subscriptionId: sub.id);
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cancelaste tu participación. '
            'Te devolvimos ${sub.amount.toCop()} a tu saldo.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/funds');
    } else {
      final lastError =
          ref.read(subscriptionNotifierProvider.notifier).lastError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lastError ?? 'No pudimos cancelar la suscripción.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubscribed = activeSubscription != null;
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final isLoading = subscriptionState is SubscriptionLoading;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        screenPadding(context).left,
        AppSpacing.md,
        screenPadding(context).right,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  fund.name,
                  style: AppTextStyles.headingLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FundCategoryBadge(category: fund.category),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _categoryDescription(fund.category),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monto mínimo de apertura',
                        style: AppTextStyles.labelSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      MoneyDisplay(
                        amount: fund.minimumAmount,
                        style: AppTextStyles.moneyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (fund.description.isNotEmpty) ...[
            Text(
              fund.description,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (isSubscribed) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ya tienes una participación activa por',
                    style: AppTextStyles.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  MoneyDisplay(
                    amount: activeSubscription!.amount,
                    style: AppTextStyles.moneyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: isLoading ? null : () => _onCancel(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.brandGold,
                        ),
                      ),
                    )
                  : const Text('Cancelar participación'),
            ),
          ] else
            AppButton(
              label: 'Suscribirme',
              onPressed: () => context.go('/funds/${fund.id}/subscribe'),
            ),
        ],
      ),
    );
  }
}
