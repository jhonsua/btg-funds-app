import 'package:flutter/material.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/core/theme/app_elevation.dart';
import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/shared/widgets/app_skeleton.dart';

/// Placeholder shimmer que imita la estructura visual de `TransactionCard`:
/// badge de tipo (suscripción/cancelación), fecha, nombre del fondo y monto.
/// Se muestra durante el AsyncLoading de la lista de transacciones.
class TransactionCardSkeleton extends StatelessWidget {
  const TransactionCardSkeleton({super.key});

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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSkeleton(width: 80, height: 20, borderRadius: 4),
              Spacer(),
              AppSkeleton(width: 70, height: 12),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          AppSkeleton(width: 180, height: 16),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              AppSkeleton(width: 130, height: 12),
              Spacer(),
              AppSkeleton(width: 110, height: 18),
            ],
          ),
        ],
      ),
    );
  }
}
