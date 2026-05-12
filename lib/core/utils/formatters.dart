import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:btg_funds_app/core/constants/app_constants.dart';

extension MoneyFormat on num {
  String toCop({bool showSymbol = true}) {
    final isNegative = this < 0;
    final magnitude = NumberFormat.decimalPattern(kBaseLocale)
        .format(isNegative ? -this : this);
    if (!showSymbol) {
      return isNegative ? '-$magnitude' : magnitude;
    }
    return isNegative ? '-COP \$$magnitude' : 'COP \$$magnitude';
  }
}

class ThousandsSeparatorFormatter extends TextInputFormatter {
  static final NumberFormat _format = NumberFormat.decimalPattern(kBaseLocale);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    final digitsLeftOfCursor = _digitsLeftOfCursor(
      newValue.text,
      newValue.selection.baseOffset,
    );

    final number = int.tryParse(digitsOnly);
    if (number == null) {
      return oldValue;
    }
    final formatted = _format.format(number);

    final newCursor = _cursorForDigitCount(formatted, digitsLeftOfCursor);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }

  static int _digitsLeftOfCursor(String text, int cursor) {
    if (cursor < 0) return 0;
    final clamped = cursor > text.length ? text.length : cursor;
    var count = 0;
    for (var i = 0; i < clamped; i++) {
      if (_isDigit(text.codeUnitAt(i))) count++;
    }
    return count;
  }

  static int _cursorForDigitCount(String formatted, int digitsLeft) {
    if (digitsLeft <= 0) return 0;
    var seen = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (_isDigit(formatted.codeUnitAt(i))) {
        seen++;
        if (seen == digitsLeft) return i + 1;
      }
    }
    return formatted.length;
  }

  static bool _isDigit(int codeUnit) => codeUnit >= 0x30 && codeUnit <= 0x39;
}
