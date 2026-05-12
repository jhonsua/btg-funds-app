import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:btg_funds_app/app/app.dart';
import 'package:btg_funds_app/core/config/app_config.dart';
import 'package:btg_funds_app/core/config/flavor.dart';
import 'package:btg_funds_app/core/constants/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(kBaseLocale);

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(
          const AppConfig(
            flavor: Flavor.dev,
            appName: 'BTG Pactual Dev',
            simulatedLatency: Duration(milliseconds: 600),
            showDebugBanner: true,
          ),
        ),
      ],
      child: const BtgApp(),
    ),
  );
}
