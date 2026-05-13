import 'package:flutter_test/flutter_test.dart';

/// Bombea frames hasta que [finder] encuentre al menos un widget o se
/// agote [timeout]. Útil cuando `pumpAndSettle` no resuelve (animaciones
/// infinitas como skeleton shimmer) o cuando hay timing impredecible
/// (ej. snackbars que aparecen tras una operación async).
///
/// Lanza [TestFailure] si el timeout se agota sin encontrar el widget.
///
/// Implementación: pumps de 100ms a 100ms. Suficiente granularidad para
/// la mayoría de transiciones del proyecto (220ms fade+slide del router,
/// 300ms hero balance animator).
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  if (finder.evaluate().isEmpty) {
    throw TestFailure('No se encontró $finder en $timeout');
  }
}

/// Bombea frames durante [animation] para cubrir una transición
/// específica conocida. Alternativa segura a `pumpAndSettle` cuando hay
/// `AnimationController.repeat()` infinitos en pantalla (skeleton
/// shimmer, dots de loading) que harían colgar el settle.
///
/// Default 400ms cubre las transiciones del router (220ms) con margen
/// suficiente para que la pantalla destino haga su primer build.
Future<void> pumpWithAnimations(
  WidgetTester tester, {
  Duration animation = const Duration(milliseconds: 400),
}) async {
  await tester.pump();
  await tester.pump(animation);
}
