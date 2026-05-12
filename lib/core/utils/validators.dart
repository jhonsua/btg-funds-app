class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _phoneCoRegex =
      RegExp(r'^\+57\s?3\d{2}\s?\d{3}\s?\d{4}$');
  static final RegExp _digitsOrSeparators = RegExp(r'[^\d]');

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Ingresa tu correo.';
    if (!_emailRegex.hasMatch(trimmed)) return 'Correo inválido.';
    return null;
  }

  static String? phoneCO(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Ingresa tu teléfono.';
    if (!_phoneCoRegex.hasMatch(trimmed)) {
      return 'Teléfono inválido. Usa formato +57 3XX XXX XXXX.';
    }
    return null;
  }

  static String? amount(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Ingresa un monto.';
    if (trimmed.contains(',') || trimmed.contains('.')) {
      final digits = trimmed.replaceAll(_digitsOrSeparators, '');
      if (digits != trimmed.replaceAll(RegExp(r'[.,]'), '')) {
        return 'Ingresa solo números.';
      }
      // Caso "1.234,56" o "1,234.56" → tiene decimales
      final hasDecimals = RegExp(r'[.,]\d+$').hasMatch(trimmed) &&
          !RegExp(r'^\d{1,3}([.,]\d{3})+$').hasMatch(trimmed);
      if (hasDecimals) {
        return 'El monto debe ser entero (sin decimales).';
      }
    }
    final digitsOnly = trimmed.replaceAll(_digitsOrSeparators, '');
    if (digitsOnly.isEmpty) return 'Ingresa un monto válido.';
    final parsed = int.tryParse(digitsOnly);
    if (parsed == null) return 'Ingresa un monto válido.';
    if (parsed <= 0) return 'El monto debe ser mayor a cero.';
    return null;
  }
}
