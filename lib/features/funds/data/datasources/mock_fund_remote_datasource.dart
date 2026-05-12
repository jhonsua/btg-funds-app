import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:btg_funds_app/core/errors/exceptions.dart';
import 'package:btg_funds_app/features/funds/data/datasources/fund_remote_datasource.dart';
import 'package:btg_funds_app/features/funds/data/models/fund_model.dart';

class MockFundRemoteDatasource implements FundRemoteDatasource {
  MockFundRemoteDatasource({
    required AssetBundle bundle,
    Duration latency = Duration.zero,
  })  : _bundle = bundle,
        _latency = latency;

  static const _assetPath = 'assets/mocks/funds.json';

  final AssetBundle _bundle;
  final Duration _latency;

  @override
  Future<List<FundModel>> getFunds() async {
    try {
      if (_latency > Duration.zero) {
        await Future<void>.delayed(_latency);
      }
      final raw = await _bundle.loadString(_assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const ServerException(
          'Datos corruptos: se esperaba un array de fondos.',
        );
      }
      return decoded
          .map((e) => FundModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } on FormatException catch (e) {
      throw ServerException('Datos corruptos: ${e.message}');
    } catch (e) {
      throw ServerException('Error obteniendo los fondos: $e');
    }
  }

  @override
  Future<FundModel?> getFundById(String id) async {
    final all = await getFunds();
    for (final fund in all) {
      if (fund.id == id) return fund;
    }
    return null;
  }
}
