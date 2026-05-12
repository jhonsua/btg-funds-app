import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/core/theme/app_text_styles.dart';
import 'package:btg_funds_app/core/utils/formatters.dart';
import 'package:btg_funds_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/user/presentation/providers/providers.dart';
import 'package:btg_funds_app/shared/widgets/app_card.dart';
import 'package:btg_funds_app/shared/widgets/app_loading.dart';
import 'package:btg_funds_app/shared/widgets/money_display.dart';

/// Sección reutilizable arriba de FundsListScreen con saludo, saldo,
/// invertido+total y lista resumida de posiciones activas.
class HomeDashboardSection extends ConsumerWidget {
  const HomeDashboardSection({super.key});

  String _firstName(String email) {
    if (email.isEmpty) return 'Bienvenido';
    final local = email.split('@').first;
    if (local.isEmpty) return 'Bienvenido';
    final first = local.split(RegExp('[._-]')).first;
    if (first.isEmpty) return 'Bienvenido';
    return first[0].toUpperCase() + first.substring(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userNotifierProvider);
    final subsAsync = ref.watch(subscriptionsListNotifierProvider);

    return userAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: AppLoading(),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          'No pudimos cargar tu información.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
        ),
      ),
      data: (user) {
        final greeting = 'Hola, ${_firstName(user.email)}';
        final subscriptions = subsAsync.valueOrNull ?? const <Subscription>[];
        final invested = subscriptions.fold<double>(
          0,
          (sum, s) => sum + s.amount,
        );
        final total = user.balance + invested;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(greeting, style: AppTextStyles.headingLarge),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Saldo disponible',
                      style: AppTextStyles.labelSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: MoneyDisplay(
                        amount: user.balance,
                        style: AppTextStyles.moneyHero,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricColumn(
                            label: 'Invertido',
                            amount: invested,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: AppColors.border,
                        ),
                        Expanded(
                          child: _MetricColumn(label: 'Total', amount: total),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (subscriptions.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Mis posiciones activas',
                        style: AppTextStyles.headingSmall,
                      ),
                    ),
                    if (subscriptions.length > 3)
                      TextButton(
                        onPressed: () => context.go('/positions'),
                        child: const Text('Ver todas'),
                      ),
                  ],
                ),
              ),
              ...subscriptions.take(3).map(
                    (s) => Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: AppCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.fundName,
                                    style: AppTextStyles.bodyMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Desde ${_shortDate(s.openedAt)}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            MoneyDisplay(
                              amount: s.amount,
                              style: AppTextStyles.moneyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ],
        );
      },
    );
  }

  String _shortDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelSmall),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount.toCop(),
              style: AppTextStyles.moneyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
