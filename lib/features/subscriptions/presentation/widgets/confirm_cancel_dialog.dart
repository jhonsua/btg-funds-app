import 'package:flutter/material.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/core/theme/app_text_styles.dart';
import 'package:btg_funds_app/core/utils/formatters.dart';

/// Dialog modal de confirmación antes de cancelar una suscripción.
/// Retorna `true` si el usuario confirma, `false` o `null` si descarta.
Future<bool?> showConfirmCancelDialog(
  BuildContext context, {
  required String fundName,
  required double amount,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => ConfirmCancelDialog(fundName: fundName, amount: amount),
  );
}

class ConfirmCancelDialog extends StatelessWidget {
  const ConfirmCancelDialog({
    super.key,
    required this.fundName,
    required this.amount,
  });

  final String fundName;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '¿Cancelar tu participación en $fundName?',
        style: AppTextStyles.headingMedium,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      content: Text(
        'Te devolveremos ${amount.toCop()} a tu saldo disponible.',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Volver'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.textOnDark,
          ),
          child: const Text('Sí, cancelar participación'),
        ),
      ],
    );
  }
}
