import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// Generador de UUIDs inyectable para tests determinísticos.
final uuidProvider = Provider<Uuid>((_) => const Uuid());
