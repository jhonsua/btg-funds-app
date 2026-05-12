import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/core/utils/formatters.dart';
import 'package:btg_funds_app/core/utils/responsive.dart';
import 'package:btg_funds_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/widgets/confirm_cancel_dialog.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/widgets/position_card.dart';
import 'package:btg_funds_app/shared/widgets/app_empty_view.dart';
import 'package:btg_funds_app/shared/widgets/app_error_view.dart';
import 'package:btg_funds_app/shared/widgets/app_loading.dart';

class PositionsScreen extends ConsumerWidget {
  const PositionsScreen({super.key});

  Future<void> _onCancel(
    BuildContext context,
    WidgetRef ref,
    Subscription sub,
  ) async {
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
    } else {
      final lastError =
          ref.read(subscriptionNotifierProvider.notifier).lastError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lastError ?? 'No pudimos cancelar.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subsAsync = ref.watch(subscriptionsListNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis posiciones')),
      body: centeredOnDesktop(
        context,
        subsAsync.when(
          loading: () => const AppLoading(),
          error: (e, _) => AppErrorView(message: e.toString()),
          data: (subs) {
            if (subs.isEmpty) {
              return AppEmptyView(
                icon: Icons.show_chart_outlined,
                title: 'Aún no tienes posiciones activas',
                subtitle: 'Explora los fondos disponibles para empezar.',
                actionLabel: 'Ir a fondos',
                onAction: () => context.go('/funds'),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                screenPadding(context).left,
                AppSpacing.md,
                screenPadding(context).right,
                AppSpacing.lg,
              ),
              itemCount: subs.length,
              itemBuilder: (ctx, index) {
                final sub = subs[index];
                return TweenAnimationBuilder<double>(
                  key: ValueKey('position-stagger-${sub.id}'),
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
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: PositionCard(
                      subscription: sub,
                      onTap: () => _onCancel(context, ref, sub),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
