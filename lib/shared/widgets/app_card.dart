import 'package:flutter/material.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/core/theme/app_elevation.dart';
import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/shared/widgets/animated_press.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
      boxShadow: AppElevation.low,
    );

    final surface = Container(
      decoration: decoration,
      padding: padding,
      child: child,
    );

    if (onTap == null) {
      return surface;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedPress(
        onTap: onTap,
        child: surface,
      ),
    );
  }
}
