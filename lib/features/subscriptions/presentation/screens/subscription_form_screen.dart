import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/core/theme/app_text_styles.dart';
import 'package:btg_funds_app/core/utils/formatters.dart';
import 'package:btg_funds_app/core/utils/responsive.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_app/features/funds/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/notifiers/subscription_state.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';
import 'package:btg_funds_app/features/user/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/user/presentation/widgets/channel_selector_sheet.dart';
import 'package:btg_funds_app/shared/widgets/animated_press.dart';
import 'package:btg_funds_app/shared/widgets/app_button.dart';
import 'package:btg_funds_app/shared/widgets/app_card.dart';
import 'package:btg_funds_app/shared/widgets/app_error_view.dart';
import 'package:btg_funds_app/shared/widgets/app_loading.dart';
import 'package:btg_funds_app/shared/widgets/inline_validation_message.dart';
import 'package:btg_funds_app/shared/widgets/money_display.dart';

class SubscriptionFormScreen extends ConsumerStatefulWidget {
  const SubscriptionFormScreen({super.key, required this.fundId});

  final String fundId;

  @override
  ConsumerState<SubscriptionFormScreen> createState() =>
      _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState
    extends ConsumerState<SubscriptionFormScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  NotificationChannel _channel = NotificationChannel.email;
  bool _channelInitialized = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Inicializa `_channel` con la preferencia del usuario (si existe) o
  /// con `email` como default descubrible. Sólo se ejecuta una vez.
  void _ensureChannelInitialized(UserState user) {
    if (_channelInitialized) return;
    _channel = user.preferredChannel ?? NotificationChannel.email;
    _channelInitialized = true;
  }

  double? get _amount {
    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  bool _canSubmit({
    required double minimumAmount,
    required double balance,
    required bool isLoading,
  }) {
    if (isLoading) return false;
    final amount = _amount;
    if (amount == null || amount <= 0) return false;
    if (amount != amount.truncate()) return false;
    if (amount < minimumAmount) return false;
    if (amount > balance) return false;
    return true;
  }

  Future<void> _pickChannel() async {
    final result = await showChannelSelectorSheet(
      context,
      current: _channel,
    );
    if (result == null) return;
    setState(() => _channel = result);
  }

  Future<void> _onSubmit({
    required String fundName,
    required String userEmail,
    required String userPhone,
  }) async {
    final amount = _amount!;
    final ok = await ref
        .read(subscriptionNotifierProvider.notifier)
        .subscribe(fundId: widget.fundId, amount: amount, channel: _channel);
    if (!mounted) return;
    if (ok) {
      final destination =
          _channel == NotificationChannel.email ? userEmail : userPhone;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Te suscribiste a $fundName. '
            'Confirmación enviada a $destination.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/funds');
    } else {
      final lastError =
          ref.read(subscriptionNotifierProvider.notifier).lastError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lastError ?? 'No pudimos completar tu suscripción.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fundAsync = ref.watch(fundByIdProvider(widget.fundId));
    final userAsync = ref.watch(userNotifierProvider);
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final isSubmitting = subscriptionState is SubscriptionLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Suscripción')),
      resizeToAvoidBottomInset: true,
      body: centeredOnDesktop(
        context,
        fundAsync.when(
          loading: () => const AppLoading(),
          error: (e, _) => AppErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(fundByIdProvider(widget.fundId)),
          ),
          data: (fund) => userAsync.when(
            loading: () => const AppLoading(),
            error: (e, _) => AppErrorView(message: e.toString()),
            data: (user) {
              _ensureChannelInitialized(user);
              return _FormBody(
                fund: fund,
                user: user,
                channel: _channel,
                amountController: _amountController,
                amount: _amount,
                canSubmit: _canSubmit(
                  minimumAmount: fund.minimumAmount,
                  balance: user.balance,
                  isLoading: isSubmitting,
                ),
                isSubmitting: isSubmitting,
                formKey: _formKey,
                onAmountChanged: () => setState(() {}),
                onPickChannel: _pickChannel,
                onSubmit: () => _onSubmit(
                  fundName: fund.name,
                  userEmail: user.email,
                  userPhone: user.phone,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.fund,
    required this.user,
    required this.channel,
    required this.amountController,
    required this.amount,
    required this.canSubmit,
    required this.isSubmitting,
    required this.formKey,
    required this.onAmountChanged,
    required this.onPickChannel,
    required this.onSubmit,
  });

  final Fund fund;
  final UserState user;
  final NotificationChannel channel;
  final TextEditingController amountController;
  final double? amount;
  final bool canSubmit;
  final bool isSubmitting;
  final GlobalKey<FormState> formKey;
  final VoidCallback onAmountChanged;
  final VoidCallback onPickChannel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final amt = amount;
    final remaining = (amt == null) ? user.balance : user.balance - amt;

    final showBelowMinimum = amt != null && amt > 0 && amt < fund.minimumAmount;
    final showOverBalance = amt != null && amt > user.balance;
    final showDecimal = amt != null && amt > 0 && amt != amt.truncate();

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              fund.name,
              style: AppTextStyles.headingMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Mínimo ${fund.minimumAmount.toCop()}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              '¿Cuánto deseas invertir?',
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorFormatter(),
              ],
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                prefixText: r'COP $ ',
                prefixStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                hintText: '0',
              ),
              onChanged: (_) => onAmountChanged(),
            ),
            if (showBelowMinimum)
              InlineValidationMessage(
                severity: InlineValidationSeverity.warning,
                title: 'Monto menor al mínimo',
                description: 'Este fondo requiere un monto de apertura mayor.',
                contexts: [
                  InlineValidationContext(
                    label: 'Monto mínimo',
                    value: fund.minimumAmount.toCop(),
                  ),
                  InlineValidationContext(
                    label: 'Tu intento',
                    value: amt.toCop(),
                  ),
                ],
              ),
            if (showOverBalance)
              InlineValidationMessage(
                title: 'Saldo insuficiente',
                description:
                    'El monto supera tu saldo disponible. Reduce el valor '
                    'o cancela una posición activa para liberar saldo.',
                contexts: [
                  InlineValidationContext(
                    label: 'Tu intento',
                    value: amt.toCop(),
                  ),
                  InlineValidationContext(
                    label: 'Saldo disponible',
                    value: user.balance.toCop(),
                  ),
                ],
              ),
            if (showDecimal)
              const InlineValidationMessage(
                title: 'Monto inválido',
                description:
                    'Los aportes en pesos colombianos deben ser cifras '
                    'enteras, sin decimales.',
              ),
            const SizedBox(height: AppSpacing.lg),
            _ChannelTile(
              channel: channel,
              user: user,
              onTap: onPickChannel,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resumen', style: AppTextStyles.labelSmall),
                  const SizedBox(height: AppSpacing.sm),
                  _SummaryRow(
                    label: 'Vas a invertir',
                    child: MoneyDisplay(
                      amount: amt ?? 0,
                      style: AppTextStyles.moneyMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _SummaryRow(
                    label: 'Saldo después',
                    child: MoneyDisplay(
                      amount: remaining < 0 ? 0 : remaining,
                      style: AppTextStyles.moneyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AnimatedPress(
              onTap: canSubmit ? onSubmit : null,
              child: AppButton(
                label: 'Confirmar suscripción',
                isLoading: isSubmitting,
                onPressed: canSubmit ? onSubmit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  const _ChannelTile({
    required this.channel,
    required this.user,
    required this.onTap,
  });

  final NotificationChannel channel;
  final UserState user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEmail = channel == NotificationChannel.email;
    final destination = isEmail ? user.email : user.phone;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  isEmail ? Icons.email_outlined : Icons.sms_outlined,
                  color: AppColors.brandGoldDark,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Te avisamos por',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        destination,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Cambiar',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.brandGoldDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
        child,
      ],
    );
  }
}
