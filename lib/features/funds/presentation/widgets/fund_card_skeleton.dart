import 'package:flutter/material.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/core/theme/app_elevation.dart';
import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/shared/widgets/app_skeleton.dart';

/// Placeholder shimmer que imita la estructura visual de `FundCard`:
/// nombre del fondo (línea larga), badge de categoría, monto mínimo y un
/// pequeño bloque inferior. Se muestra durante el AsyncLoading del
/// listado de fondos para evitar el "salto" de pantalla vacía a data.
class FundCardSkeleton extends StatelessWidget {
  const FundCardSkeleton({super.key});

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
              Expanded(
                child: AppSkeleton(width: double.infinity, height: 18),
              ),
              SizedBox(width: AppSpacing.sm),
              AppSkeleton(width: 56, height: 22, borderRadius: 4),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppSkeleton(width: 140, height: 14),
              ),
              SizedBox(width: AppSpacing.sm),
              AppSkeleton(width: 80, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}
