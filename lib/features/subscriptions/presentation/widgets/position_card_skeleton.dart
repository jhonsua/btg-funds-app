import 'package:flutter/material.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/core/theme/app_elevation.dart';
import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/shared/widgets/app_skeleton.dart';

/// Placeholder shimmer que imita la estructura visual de `PositionCard`:
/// nombre del fondo, fecha de apertura y monto invertido. Se muestra
/// durante el AsyncLoading de la lista de posiciones.
class PositionCardSkeleton extends StatelessWidget {
  const PositionCardSkeleton({super.key});

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
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(width: 180, height: 18),
                SizedBox(height: AppSpacing.xs),
                AppSkeleton(width: 100, height: 12),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          AppSkeleton(width: 90, height: 20),
        ],
      ),
    );
  }
}
