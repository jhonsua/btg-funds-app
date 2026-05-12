import 'package:flutter/material.dart';

/// Sistema de elevación premium.
///
/// Cuatro niveles de sombras pensadas para banca premium: sutiles, nunca
/// agresivas (opacity ≤ 0.08, blur ≤ 24). Una tarjeta lleva sombra Y border
/// 1dp; la sombra define elevación, el border define recorte limpio.
class AppElevation {
  AppElevation._();

  /// Nivel 0 — superficie plana (fondo de pantalla, sin elevación).
  static const List<BoxShadow> none = [];

  /// Nivel 1 — tarjetas estándar, bordes apenas perceptibles.
  /// Para FundCard, PositionCard, TransactionCard.
  static const List<BoxShadow> low = [
    BoxShadow(
      color: Color(0x0A000000), // opacity 0.04
      blurRadius: 12,
      offset: Offset(0, 2),
    ),
  ];

  /// Nivel 2 — tarjetas hero, dashboard prominente, modales inline.
  /// Para HomeDashboardSection.balance card, FundDetail hero section.
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x0F000000), // opacity 0.06
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x05000000), // opacity 0.02
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Nivel 3 — bottom sheets, dialogs, overlays flotantes.
  static const List<BoxShadow> high = [
    BoxShadow(
      color: Color(0x14000000), // opacity 0.08
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// Nivel especial — pressed/focused state (sombra hacia arriba sutil).
  static const List<BoxShadow> pressed = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 1),
    ),
  ];
}
