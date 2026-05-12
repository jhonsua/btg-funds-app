import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/core/theme/app_elevation.dart';
import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/core/theme/app_text_styles.dart';
import 'package:btg_funds_app/core/utils/formatters.dart';
import 'package:btg_funds_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/user/presentation/providers/providers.dart';
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
            // ── HERO premium: saldo disponible en negro brand ───────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: _HeroBalanceCard(balance: user.balance),
            ),
            // ── STANDARD card: invertido + total ────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: _InvestedTotalCard(invested: invested, total: total),
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
                      child: _PositionSummaryCard(subscription: s),
                    ),
                  ),
            ],
          ],
        );
      },
    );
  }
}

/// Hero negro premium con saldo disponible. Cifra animada con
/// `AnimatedSwitcher` (fade + slide vertical) y firma de marca dorada.
///
/// Es `StatefulWidget` para diferir la actualización del valor mostrado
/// hasta que el widget esté efectivamente visible (`TickerMode == true`).
/// Esto evita que la transición de 300ms corra mientras Home está offstage
/// dentro del `IndexedStack` del `StatefulShellRoute`, lo cual provocaba
/// que el usuario percibiera un cambio brusco al regresar a la pestaña.
class _HeroBalanceCard extends StatefulWidget {
  const _HeroBalanceCard({required this.balance});

  final double balance;

  @override
  State<_HeroBalanceCard> createState() => _HeroBalanceCardState();
}

class _HeroBalanceCardState extends State<_HeroBalanceCard> {
  late double _displayedBalance;

  @override
  void initState() {
    super.initState();
    _displayedBalance = widget.balance;
  }

  @override
  void didUpdateWidget(_HeroBalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.balance != widget.balance) {
      _scheduleDisplayUpdate();
    }
  }

  /// Espera al próximo frame y aplica el nuevo balance solo cuando el
  /// widget esté visible (TickerMode habilitado). Si está offstage, vuelve
  /// a programar el chequeo en el siguiente frame para que la animación
  /// arranque cuando el usuario realmente esté viendo el hero.
  void _scheduleDisplayUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_displayedBalance == widget.balance) return;
      if (TickerMode.valuesOf(context).enabled) {
        setState(() => _displayedBalance = widget.balance);
      } else {
        _scheduleDisplayUpdate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brandBlack,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppElevation.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.brandGold,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Saldo disponible',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textOnDark.withValues(alpha: 0.7),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: FittedBox(
              key: ValueKey(_displayedBalance),
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: MoneyDisplay(
                amount: _displayedBalance,
                style: AppTextStyles.moneyHero.copyWith(
                  color: AppColors.textOnDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Standard card blanca con invertido + total. Subordinada al hero negro
/// que vive arriba; usa `AppElevation.low` y radius 12 (no 16).
class _InvestedTotalCard extends StatelessWidget {
  const _InvestedTotalCard({required this.invested, required this.total});

  final double invested;
  final double total;

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
      child: Row(
        children: [
          Expanded(
            child: _MetricColumn(label: 'Invertido', amount: invested),
          ),
          Container(width: 1, height: 36, color: AppColors.border),
          Expanded(
            child: _MetricColumn(label: 'Total', amount: total),
          ),
        ],
      ),
    );
  }
}

/// Card resumida de una posición activa. Pertenece al tier standard,
/// no compite visualmente con el hero.
class _PositionSummaryCard extends StatelessWidget {
  const _PositionSummaryCard({required this.subscription});

  final Subscription subscription;

  String _shortDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.fundName,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Desde ${_shortDate(subscription.openedAt)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          MoneyDisplay(
            amount: subscription.amount,
            style: AppTextStyles.moneyMedium,
          ),
        ],
      ),
    );
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
            child: Text(amount.toCop(), style: AppTextStyles.moneyMedium),
          ),
        ],
      ),
    );
  }
}
