import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/core/theme/app_text_styles.dart';
import 'package:btg_funds_app/core/utils/responsive.dart';
import 'package:btg_funds_app/features/funds/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/funds/presentation/widgets/fund_card.dart';
import 'package:btg_funds_app/features/funds/presentation/widgets/fund_card_skeleton.dart';
import 'package:btg_funds_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/user/presentation/widgets/home_dashboard_section.dart';
import 'package:btg_funds_app/shared/widgets/app_error_view.dart';

class FundsListScreen extends ConsumerWidget {
  const FundsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fundsAsync = ref.watch(fundsNotifierProvider);
    final subscriptions =
        ref.watch(subscriptionsListNotifierProvider).valueOrNull ??
            const <Subscription>[];
    final subscribedFundIds = subscriptions.map((s) => s.fundId).toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('BTG Pactual')),
      body: centeredOnDesktop(
        context,
        fundsAsync.when(
          loading: () => ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const HomeDashboardSection(),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  screenPadding(context).left,
                  AppSpacing.md,
                  screenPadding(context).right,
                  AppSpacing.sm,
                ),
                child: const Text(
                  'Fondos disponibles',
                  style: AppTextStyles.headingMedium,
                ),
              ),
              for (var i = 0; i < 5; i++)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    screenPadding(context).left,
                    0,
                    screenPadding(context).right,
                    AppSpacing.sm,
                  ),
                  child: const FundCardSkeleton(),
                ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
          error: (e, _) => AppErrorView(
            message: e.toString(),
            onRetry: () => ref.read(fundsNotifierProvider.notifier).refresh(),
          ),
          data: (funds) => RefreshIndicator(
            onRefresh: () => ref.read(fundsNotifierProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const HomeDashboardSection(),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    screenPadding(context).left,
                    AppSpacing.md,
                    screenPadding(context).right,
                    AppSpacing.sm,
                  ),
                  child: const Text(
                    'Fondos disponibles',
                    style: AppTextStyles.headingMedium,
                  ),
                ),
                for (var i = 0; i < funds.length; i++)
                  TweenAnimationBuilder<double>(
                    key: ValueKey('fund-stagger-${funds[i].id}'),
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 250 + i * 50),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - value)),
                        child: child,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        screenPadding(context).left,
                        0,
                        screenPadding(context).right,
                        AppSpacing.sm,
                      ),
                      child: FundCard(
                        fund: funds[i],
                        isSubscribed: subscribedFundIds.contains(funds[i].id),
                        onTap: () => context.go('/funds/${funds[i].id}'),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
