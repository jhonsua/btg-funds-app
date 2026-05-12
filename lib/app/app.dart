import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:btg_funds_app/core/config/app_config.dart';
import 'package:btg_funds_app/core/theme/app_spacing.dart';
import 'package:btg_funds_app/core/theme/app_text_styles.dart';
import 'package:btg_funds_app/core/theme/app_theme.dart';

class BtgApp extends ConsumerWidget {
  const BtgApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: config.showDebugBanner,
      theme: AppTheme.light,
      home: _BtgPlaceholderScreen(appName: config.appName),
    );
  }
}

class _BtgPlaceholderScreen extends StatelessWidget {
  const _BtgPlaceholderScreen({required this.appName});

  final String appName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appName)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Text(
            appName,
            style: AppTextStyles.displayMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
