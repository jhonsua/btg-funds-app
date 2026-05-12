import 'package:flutter/material.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/core/theme/app_text_styles.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';

/// Bottom sheet modal para elegir [NotificationChannel].
/// Retorna `null` si el usuario lo descarta sin elegir.
Future<NotificationChannel?> showChannelSelectorSheet(
  BuildContext context, {
  NotificationChannel? current,
  String? title,
}) {
  return showModalBottomSheet<NotificationChannel>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _ChannelSelectorSheet(
      current: current,
      title: title ?? '¿Cómo te avisamos?',
    ),
  );
}

class _ChannelSelectorSheet extends StatelessWidget {
  const _ChannelSelectorSheet({required this.current, required this.title});

  final NotificationChannel? current;
  final String title;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: AppTextStyles.headingMedium),
              const SizedBox(height: AppSpacing.md),
              _Option(
                label: 'Correo',
                icon: Icons.email_outlined,
                selected: current == NotificationChannel.email,
                onTap: () => Navigator.pop(context, NotificationChannel.email),
              ),
              const SizedBox(height: AppSpacing.sm),
              _Option(
                label: 'SMS',
                icon: Icons.sms_outlined,
                selected: current == NotificationChannel.sms,
                onTap: () => Navigator.pop(context, NotificationChannel.sms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? AppColors.brandBlack : AppColors.border,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(label, style: AppTextStyles.labelLarge)),
              if (selected)
                const Icon(Icons.check, color: AppColors.brandBlack),
            ],
          ),
        ),
      ),
    );
  }
}
