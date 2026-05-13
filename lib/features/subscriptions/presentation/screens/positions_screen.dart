import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/core/utils/responsive.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/widgets/position_card.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/widgets/position_card_skeleton.dart';
import 'package:btg_funds_app/shared/widgets/app_empty_view.dart';
import 'package:btg_funds_app/shared/widgets/app_error_view.dart';

class PositionsScreen extends ConsumerWidget {
  const PositionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subsAsync = ref.watch(subscriptionsListNotifierProvider);

    return Scaffold(
      key: const ValueKey('positions-screen'),
      appBar: AppBar(title: const Text('Mis posiciones')),
      body: centeredOnDesktop(
        context,
        subsAsync.when(
          loading: () => ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              screenPadding(context).left,
              AppSpacing.md,
              screenPadding(context).right,
              AppSpacing.lg,
            ),
            itemCount: 3,
            itemBuilder: (ctx, _) => const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: PositionCardSkeleton(),
            ),
          ),
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
                      onTap: () => context.push('/funds/${sub.fundId}'),
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
