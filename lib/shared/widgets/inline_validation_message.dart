import 'package:flutter/material.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/core/theme/app_text_styles.dart';

enum InlineValidationSeverity { error, warning, info }

class InlineValidationContext {
  const InlineValidationContext({required this.label, required this.value});

  final String label;
  final String value;
}

/// Mensaje de validación enriquecido que aparece debajo de un input.
/// Soporta tres severidades y una lista opcional de `contexts` (pares
/// label→valor) para mostrar comparaciones tabulares.
class InlineValidationMessage extends StatelessWidget {
  const InlineValidationMessage({
    super.key,
    required this.title,
    required this.description,
    this.contexts = const [],
    this.severity = InlineValidationSeverity.error,
  });

  final String title;
  final String description;
  final List<InlineValidationContext> contexts;
  final InlineValidationSeverity severity;

  Color get _bgColor {
    switch (severity) {
      case InlineValidationSeverity.error:
        return AppColors.errorLight;
      case InlineValidationSeverity.warning:
        return AppColors.warningLight;
      case InlineValidationSeverity.info:
        return AppColors.infoLight;
    }
  }

  Color get _borderColor {
    switch (severity) {
      case InlineValidationSeverity.error:
        return AppColors.error;
      case InlineValidationSeverity.warning:
        return AppColors.warning;
      case InlineValidationSeverity.info:
        return AppColors.info;
    }
  }

  IconData get _icon {
    switch (severity) {
      case InlineValidationSeverity.error:
        return Icons.error_outline;
      case InlineValidationSeverity.warning:
        return Icons.warning_amber_outlined;
      case InlineValidationSeverity.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _borderColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icon, color: _borderColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: _borderColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (contexts.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...contexts.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 2,
                              child: Text(
                                '${c.label}:',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              flex: 3,
                              child: Text(
                                c.value,
                                textAlign: TextAlign.right,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
