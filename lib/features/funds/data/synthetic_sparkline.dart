import 'dart:math';

/// Genera una serie sintética determinística de [points] valores a partir de
/// [seed]. Misma seed → misma serie, garantizando reproducibilidad
/// test-a-test y consistencia visual por fondo entre sesiones.
///
/// - [start]: valor inicial de la serie (default 100).
/// - [drift]: tendencia diaria sutil agregada en cada paso (default 0.003).
/// - [volatility]: amplitud del ruido día a día (default 0.012).
///
/// El uso típico es alimentar `FundSparkline` con `seed: fund.id` para que
/// cada fondo conserve siempre la misma silueta histórica ilustrativa.
List<double> generateSparkline({
  required String seed,
  int points = 30,
  double start = 100,
  double drift = 0.003,
  double volatility = 0.012,
}) {
  final random = Random(seed.hashCode);
  final values = <double>[start];
  for (var i = 1; i < points; i++) {
    final lastValue = values.last;
    final change = drift + (random.nextDouble() - 0.5) * volatility * 2;
    values.add(lastValue * (1 + change));
  }
  return values;
}
