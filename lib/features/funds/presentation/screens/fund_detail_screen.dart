import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/core/theme/app_elevation.dart';
import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/core/theme/app_text_styles.dart';
import 'package:btg_funds_app/core/utils/formatters.dart';
import 'package:btg_funds_app/core/utils/responsive.dart';
import 'package:btg_funds_app/features/funds/data/synthetic_sparkline.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund_category.dart';
import 'package:btg_funds_app/features/funds/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/funds/presentation/widgets/fund_category_badge.dart';
import 'package:btg_funds_app/features/funds/presentation/widgets/fund_sparkline.dart';
import 'package:btg_funds_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/notifiers/subscription_state.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/widgets/confirm_cancel_dialog.dart';
import 'package:btg_funds_app/shared/widgets/animated_press.dart';
import 'package:btg_funds_app/shared/widgets/app_button.dart';
import 'package:btg_funds_app/shared/widgets/app_error_view.dart';
import 'package:btg_funds_app/shared/widgets/app_loading.dart';
import 'package:btg_funds_app/shared/widgets/money_display.dart';

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
    final sparklineData = generateSparkline(seed: fund.id);

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
          // ── HERO card: sparkline decorativo ──────────────────────
          _HeroSparklineCard(
            data: sparklineData,
            category: fund.category,
          ),
          const SizedBox(height: AppSpacing.md),
          // ── STANDARD card: descripción + monto mínimo ────────────
          _FundInfoCard(fund: fund),
          if (isSubscribed) ...[
            const SizedBox(height: AppSpacing.md),
            _ActiveParticipationCard(amount: activeSubscription!.amount),
            const SizedBox(height: AppSpacing.md),
            AnimatedPress(
              onTap: isLoading ? null : () => _onCancel(context, ref),
              child: OutlinedButton(
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
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.lg),
            AnimatedPress(
              onTap: () => context.go('/funds/${fund.id}/subscribe'),
              child: AppButton(
                label: 'Suscribirme',
                onPressed: () => context.go('/funds/${fund.id}/subscribe'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Card hero blanca con sparkline decorativo. Comunica "producto financiero
/// serio" sin tocar lógica de negocio. Badge "Ilustrativo" recuerda al
/// usuario que los datos son simulados.
class _HeroSparklineCard extends StatelessWidget {
  const _HeroSparklineCard({required this.data, required this.category});

  final List<double> data;
  final FundCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppElevation.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rendimiento histórico',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FundSparkline(data: data, category: category),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Últimos 30 días',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'Ilustrativo',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card estándar blanca con descripción educativa + monto mínimo.
/// Tier standard: `AppElevation.low`, radius 12, border 1dp.
class _FundInfoCard extends StatelessWidget {
  const _FundInfoCard({required this.fund});

  final Fund fund;

  @override
  Widget build(BuildContext context) {
    final hasDescription = fund.description.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppElevation.low,
      ),
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
          if (hasDescription) ...[
            const SizedBox(height: AppSpacing.md),
            Container(height: 1, color: AppColors.border),
            const SizedBox(height: AppSpacing.md),
            Text(
              fund.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Card que comunica al usuario que ya tiene una participación activa
/// en este fondo. Usa el mismo tier visual que las cards estándar.
class _ActiveParticipationCard extends StatelessWidget {
  const _ActiveParticipationCard({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppElevation.low,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ya tienes una participación activa por',
            style: AppTextStyles.labelSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          MoneyDisplay(amount: amount, style: AppTextStyles.moneyLarge),
        ],
      ),
    );
  }
}
