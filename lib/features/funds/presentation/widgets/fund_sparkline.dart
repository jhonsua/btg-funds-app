import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:btg_funds_app/core/theme/app_colors.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund_category.dart';

/// Mini-gráfica decorativa para FundDetail.
///
/// Comunica "este es un producto financiero serio" sin tocar lógica de
/// negocio. Los datos provienen de `generateSparkline` (sintéticos
/// determinísticos por seed) y la interacción está deshabilitada — la
/// gráfica es ambiente, no dato exacto.
///
/// El color del trazo sigue la categoría del fondo: azul para FPV, marrón
/// sobrio para FIC. Por debajo, gradient sutil 0.15 → 0.0 que aporta
/// profundidad sin saturar.
class FundSparkline extends StatelessWidget {
  final List<double> data;
  final FundCategory category;

  const FundSparkline({
    super.key,
    required this.data,
    required this.category,
  });

  Color get _lineColor => category == FundCategory.fpv
      ? AppColors.categoryFPV
      : AppColors.categoryFIC;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          maxX: data.length.toDouble() - 1,
          minY: data.reduce((a, b) => a < b ? a : b) * 0.95,
          maxY: data.reduce((a, b) => a > b ? a : b) * 1.05,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                data.length,
                (i) => FlSpot(i.toDouble(), data[i]),
              ),
              isCurved: true,
              color: _lineColor,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _lineColor.withValues(alpha: 0.15),
                    _lineColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
