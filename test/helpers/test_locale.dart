import 'package:intl/date_symbol_data_local.dart';

import 'package:btg_funds_app/core/constants/app_constants.dart';

Future<void> setupTestLocale() async {
  await initializeDateFormatting(kBaseLocale);
}
