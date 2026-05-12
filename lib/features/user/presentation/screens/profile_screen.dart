import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/core/theme/app_text_styles.dart';
import 'package:btg_funds_app/core/utils/responsive.dart';
import 'package:btg_funds_app/core/utils/validators.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/notifiers/subscription_state.dart';
import 'package:btg_funds_app/features/subscriptions/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/user/domain/entities/notification_channel.dart';
import 'package:btg_funds_app/features/user/presentation/providers/providers.dart';
import 'package:btg_funds_app/features/user/presentation/widgets/channel_selector_sheet.dart';
import 'package:btg_funds_app/shared/widgets/animated_press.dart';
import 'package:btg_funds_app/shared/widgets/app_button.dart';
import 'package:btg_funds_app/shared/widgets/app_error_view.dart';
import 'package:btg_funds_app/shared/widgets/app_loading.dart';
import 'package:btg_funds_app/shared/widgets/inline_validation_message.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  NotificationChannel? _channel;

  // Snapshot del estado inicial para detectar cambios sin guardar.
  String _initialEmail = '';
  String _initialPhone = '';
  NotificationChannel? _initialChannel;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  bool _canSave({required bool isLoading}) {
    if (isLoading) return false;
    final email = _emailController.text;
    final phone = _phoneController.text;
    if (email.isEmpty || phone.isEmpty) return false;
    if (Validators.email(email) != null) return false;
    if (Validators.phoneCO(phone) != null) return false;
    if (email == _initialEmail &&
        phone == _initialPhone &&
        _channel == _initialChannel) {
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    final ok = await ref.read(userNotifierProvider.notifier).updateProfile(
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          preferredChannel: _channel,
        );
    if (!mounted) return;
    final lastError = ref.read(userNotifierProvider.notifier).lastError;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Perfil actualizado.' : lastError ?? 'No pudimos guardar.',
        ),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
    if (ok) {
      setState(() {
        _initialEmail = _emailController.text;
        _initialPhone = _phoneController.text;
        _initialChannel = _channel;
      });
    }
  }

  Future<void> _pickChannel() async {
    final result = await showChannelSelectorSheet(context, current: _channel);
    if (result == null) return;
    setState(() => _channel = result);
  }

  Future<void> _resetDemo() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restablecer cuenta de demo'),
        content: const Text(
          'Volverás al saldo inicial de COP \$500.000 y se borrará tu '
          'historial. ¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnDark,
            ),
            child: const Text('Sí, restablecer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    final ok = await ref.read(userNotifierProvider.notifier).resetDemo();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Cuenta restablecida al estado inicial.'
              : ref.read(userNotifierProvider.notifier).lastError ??
                  'No pudimos restablecer.',
        ),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userNotifierProvider);
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final hasPendingOperation = subscriptionState is SubscriptionLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      resizeToAvoidBottomInset: true,
      body: centeredOnDesktop(
        context,
        userAsync.when(
          loading: () => const AppLoading(),
          error: (e, _) => AppErrorView(message: e.toString()),
          data: (user) {
            if (!_initialized) {
              _emailController.text = user.email;
              _phoneController.text = user.phone;
              _channel = user.preferredChannel;
              _initialEmail = user.email;
              _initialPhone = user.phone;
              _initialChannel = user.preferredChannel;
              _initialized = true;
            }

            final emailText = _emailController.text;
            final phoneText = _phoneController.text;
            final emailInvalid =
                emailText.isNotEmpty && Validators.email(emailText) != null;
            final phoneInvalid =
                phoneText.isNotEmpty && Validators.phoneCO(phoneText) != null;

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Tu información',
                      style: AppTextStyles.headingMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Correo'),
                    ),
                    if (emailInvalid)
                      const InlineValidationMessage(
                        title: 'Correo electrónico inválido',
                        description:
                            'Verifica que tenga formato correcto (ejemplo: '
                            'nombre@dominio.com). Sin un correo válido no '
                            'podremos enviarte las confirmaciones de tus '
                            'suscripciones.',
                      ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        hintText: '+57 300 000 0000',
                      ),
                    ),
                    if (phoneInvalid)
                      const InlineValidationMessage(
                        title: 'Teléfono inválido',
                        description:
                            'Usa formato colombiano con código de país: +57 '
                            'seguido de tu número de celular (10 dígitos). '
                            'Ejemplo: +57 300 123 4567.',
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'Canal preferido',
                      style: AppTextStyles.labelSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: _pickChannel,
                      icon: const Icon(Icons.notifications_outlined),
                      label: Text(
                        _channel == null
                            ? 'Preguntar cada vez'
                            : _channel!.label,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AnimatedPress(
                      onTap: _canSave(isLoading: false) ? _save : null,
                      child: AppButton(
                        label: 'Guardar cambios',
                        onPressed: _canSave(isLoading: false) ? _save : null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Text('Demo', style: AppTextStyles.labelSmall),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: hasPendingOperation ? null : _resetDemo,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Restablecer cuenta de demo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                    if (hasPendingOperation)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          'Espera a que termine la operación actual.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xl),
                    Center(
                      child: Text(
                        'v1.0.0 · PersonalSoft',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
