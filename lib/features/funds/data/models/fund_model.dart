import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_app/features/funds/domain/entities/fund_category.dart';

class FundModel {
  const FundModel({
    required this.id,
    required this.name,
    required this.minimumAmount,
    required this.category,
    this.description = '',
  });

  final String id;
  final String name;
  final double minimumAmount;
  final FundCategory category;
  final String description;

  /// Parsea defensivamente:
  /// - `id` y `name`: requeridos. Si faltan → [ServerException].
  /// - `minimum_amount`: requerido (dato crítico de negocio). Si falta → [ServerException].
  /// - `category`: default `fic` si falta o si el valor no matchea un enum
  ///   conocido (degradación grácil; las categorías son visuales y no
  ///   bloquean la transacción).
  /// - `description`: default `''` si falta (texto educativo, opcional).
  factory FundModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    if (id == null || id.isEmpty) {
      throw const ServerException('Datos corruptos: id requerido en fondo.');
    }
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      throw const ServerException('Datos corruptos: name requerido en fondo.');
    }
    final rawMinimum = json['minimum_amount'];
    if (rawMinimum == null) {
      throw const ServerException(
        'Datos corruptos: minimum_amount requerido en fondo.',
      );
    }
    if (rawMinimum is! num) {
      throw const ServerException(
        'Datos corruptos: minimum_amount debe ser numérico.',
      );
    }

    return FundModel(
      id: id,
      name: name,
      minimumAmount: rawMinimum.toDouble(),
      category: _categoryFromName(json['category'] as String?),
      description: (json['description'] as String?) ?? '',
    );
  }

  Fund toEntity() => Fund(
        id: id,
        name: name,
        minimumAmount: minimumAmount,
        category: category,
        description: description,
      );

  static FundCategory _categoryFromName(String? name) {
    if (name == null || name.isEmpty) return FundCategory.fic;
    try {
      return FundCategory.values.byName(name);
    } catch (_) {
      return FundCategory.fic;
    }
  }
}
