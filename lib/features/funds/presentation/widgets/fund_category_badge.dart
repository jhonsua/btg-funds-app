import 'package:flutter/material.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/core/theme/app_text_styles.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund_category.dart';

class FundCategoryBadge extends StatelessWidget {
  const FundCategoryBadge({super.key, required this.category});

  final FundCategory category;

  @override
  Widget build(BuildContext context) {
    final color = category == FundCategory.fpv
        ? AppColors.categoryFPV
        : AppColors.categoryFIC;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category.label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
