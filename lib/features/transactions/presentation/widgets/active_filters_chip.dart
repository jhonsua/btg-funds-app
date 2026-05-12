import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/features/funds/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_filter.dart';
import 'package:btg_funds_app/features/transactions/domain/entities/transaction_type.dart';
import 'package:btg_funds_app/features/transactions/presentation/providers/providers.dart';

class ActiveFiltersChips extends ConsumerWidget {
  const ActiveFiltersChips({super.key, required this.filter});

  final TransactionFilter filter;

  String _typeLabel(TransactionType type) =>
      type == TransactionType.subscription ? 'Suscripción' : 'Cancelación';

  String _shortDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (filter.isEmpty) return const SizedBox.shrink();

    final notifier = ref.read(transactionsNotifierProvider.notifier);
    final fundsAsync = ref.watch(fundsNotifierProvider);
    final funds = fundsAsync.valueOrNull ?? const [];

    final chips = <Widget>[];

    if (filter.type != null) {
      chips.add(
        _Chip(
          label: 'Tipo: ${_typeLabel(filter.type!)}',
          onRemove: () => notifier.applyFilter(filter.copyWith(type: null)),
        ),
      );
    }
    if (filter.fundId != null) {
      String fundLabel = filter.fundId!;
      for (final f in funds) {
        if (f.id == filter.fundId) {
          fundLabel = f.name;
          break;
        }
      }
      chips.add(
        _Chip(
          label: 'Fondo: $fundLabel',
          onRemove: () => notifier.applyFilter(filter.copyWith(fundId: null)),
        ),
      );
    }
    if (filter.dateRange != null) {
      final r = filter.dateRange!;
      chips.add(
        _Chip(
          label: '${_shortDate(r.start)} → ${_shortDate(r.end)}',
          onRemove: () =>
              notifier.applyFilter(filter.copyWith(dateRange: null)),
        ),
      );
    }
    chips.add(
      _Chip(
        label: 'Limpiar todo',
        onRemove: notifier.clearFilter,
        emphasis: true,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: chips,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.onRemove,
    this.emphasis = false,
  });

  final String label;
  final VoidCallback onRemove;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InputChip(
        label: Text(label),
        onDeleted: onRemove,
        deleteIcon: const Icon(Icons.close, size: 16),
        backgroundColor: emphasis
            ? AppColors.brandGoldLight.withValues(alpha: 0.3)
            : AppColors.surfaceElevated,
        side: BorderSide(
          color: emphasis ? AppColors.brandGoldDark : AppColors.border,
        ),
      ),
    );
  }
}
