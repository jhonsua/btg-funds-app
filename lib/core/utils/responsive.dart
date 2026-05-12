import 'package:flutter/material.dart';

/// Breakpoints de pantalla según skill `btg-design-system §7.1`.
class Breakpoints {
  Breakpoints._();

  /// Móvil gama baja extrema (Galaxy A01, Moto E).
  static const double mobileNarrow = 360;

  /// Móvil estándar (Pixel, Galaxy mid-range).
  static const double mobile = 600;

  /// Tablet portrait — umbral para NavigationRail en `HomeShell`.
  static const double tablet = 900;

  /// Web desktop / tablet landscape.
  static const double desktop = 1200;
}

/// Padding lateral adaptativo: 12dp en `<360dp`, 16dp en el resto.
EdgeInsets screenPadding(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < Breakpoints.mobileNarrow) {
    return const EdgeInsets.all(12);
  }
  return const EdgeInsets.all(16);
}

/// `true` si el ancho actual es menor a `mobileNarrow` (320–359 dp).
bool isNarrow(BuildContext context) =>
    MediaQuery.sizeOf(context).width < Breakpoints.mobileNarrow;

/// Envuelve [child] en `Center + ConstrainedBox(maxWidth: 800)` cuando
/// el ancho es `>= desktop`. En anchos menores retorna [child] tal cual.
Widget centeredOnDesktop(BuildContext context, Widget child) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= Breakpoints.desktop) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: child,
      ),
    );
  }
  return child;
}
