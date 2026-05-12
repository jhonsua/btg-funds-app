import 'package:flutter/material.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.size = 24, this.strokeWidth = 2.5});

  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor:
              const AlwaysStoppedAnimation<Color>(AppColors.brandGoldDark),
        ),
      ),
    );
  }
}
