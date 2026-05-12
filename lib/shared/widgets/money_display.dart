import 'package:flutter/material.dart';

import 'package:btg_funds_app/core/theme/app_text_styles.dart';
import 'package:btg_funds_app/core/utils/formatters.dart';

class MoneyDisplay extends StatelessWidget {
  const MoneyDisplay({
    super.key,
    required this.amount,
    this.style,
    this.showCurrency = true,
  });

  final num amount;
  final TextStyle? style;
  final bool showCurrency;

  @override
  Widget build(BuildContext context) {
    return Text(
      amount.toCop(showSymbol: showCurrency),
      style: style ?? AppTextStyles.moneyMedium,
    );
  }
}
