import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:btg_funds_app/app/home_shell.dart';
import 'package:btg_funds_app/features/funds/presentation/screens/fund_detail_screen.dart';
import 'package:btg_funds_app/features/funds/presentation/screens/funds_list_screen.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/screens/positions_screen.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/screens/subscription_form_screen.dart';
import 'package:btg_funds_app/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:btg_funds_app/features/user/presentation/screens/profile_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/funds',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/funds',
                builder: (context, state) => const FundsListScreen(),
                routes: [
                  GoRoute(
                    path: ':fundId',
                    builder: (context, state) => FundDetailScreen(
                      fundId: state.pathParameters['fundId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'subscribe',
                        builder: (context, state) => SubscriptionFormScreen(
                          fundId: state.pathParameters['fundId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/positions',
                builder: (context, state) => const PositionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
