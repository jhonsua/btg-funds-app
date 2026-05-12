import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fuente de [DateTime] inyectable para que los tests sean determinísticos
/// y los use cases no llamen `DateTime.now()` directo.
typedef Clock = DateTime Function();

final clockProvider = Provider<Clock>((_) => DateTime.now);
