import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:btg_funds_app/core/config/flavor.dart';

class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.simulatedLatency,
    required this.showDebugBanner,
  });

  final Flavor flavor;
  final String appName;
  final Duration simulatedLatency;
  final bool showDebugBanner;

  bool get isDev => flavor == Flavor.dev;
}

final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError(
    'appConfigProvider debe ser overrideado en main_dev.dart o main_prod.dart',
  ),
);
