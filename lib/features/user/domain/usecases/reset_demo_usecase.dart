import 'dart:convert';

import 'package:dartz/dartz.dart';

import 'package:btg_funds_app/core/constants/app_constants.dart';
import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/core/errors/failure.dart';
import 'package:btg_funds_app/core/storage/atomic_write.dart';
import 'package:btg_funds_app/core/storage/storage_keys.dart';
import 'package:btg_funds_app/features/user/domain/entities/user_state.dart';
import 'package:btg_funds_app/features/user/domain/repositories/user_repository.dart';

/// Restablece el estado de demo del usuario limpiando atómicamente las
/// **3 llaves críticas**: balance (→ [kInitialBalance]), subscriptions
/// (→ `[]`) y transactions (→ `[]`).
///
/// **No toca** el perfil del usuario (email, phone, preferredChannel):
/// esos datos son del usuario, no del demo.
///
/// Atomicidad vía [AtomicWrite] (mismo patrón que
/// `SubscribeToFundUseCase` y `CancelSubscriptionUseCase`). Regla del
/// proyecto: nunca mutar `shared_preferences` directamente cuando hay
/// múltiples keys interdependientes.
///
/// TODO Etapa futura: validar OperationLockRepository cross-feature
/// (SPEC_FUNCIONAL §7). La UI (ProfileScreen, Etapa 6) mitiga
/// parcialmente deshabilitando el botón "Restablecer" cuando hay
/// SubscriptionLoading activo, pero un lock real cubriría también
/// cancelaciones, transactions y futuras operaciones async.
class ResetDemoUseCase {
  ResetDemoUseCase({
    required AtomicWrite atomicWrite,
    required UserRepository userRepository,
  })  : _atomicWrite = atomicWrite,
        _userRepository = userRepository;

  final AtomicWrite _atomicWrite;
  final UserRepository _userRepository;

  Future<Either<Failure, UserState>> call() async {
    try {
      await _atomicWrite.commit({
        StorageKeys.userBalance: kInitialBalance.toString(),
        StorageKeys.userSubscriptions: jsonEncode(const <dynamic>[]),
        StorageKeys.userTransactions: jsonEncode(const <dynamic>[]),
      });
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error inesperado al restablecer: $e'));
    }

    // Releer el usuario para devolver el estado fresco (perfil intacto +
    // balance reseteado). Si esta lectura falla, propagamos el Failure:
    // la persistencia ya quedó atómicamente correcta, pero el caller
    // necesita el state para refrescar UI.
    return _userRepository.getUser();
  }
}
