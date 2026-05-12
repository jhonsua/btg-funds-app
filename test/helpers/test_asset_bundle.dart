import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// AssetBundle controlado para tests: retorna los valores en [assets]
/// indexados por path. Lanza [FlutterError] si el path no existe (mismo
/// comportamiento que rootBundle ante un asset desconocido).
class TestAssetBundle extends CachingAssetBundle {
  TestAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final value = assets[key];
    if (value == null) {
      throw FlutterError('TestAssetBundle: asset no registrado "$key"');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = assets[key];
    if (value == null) {
      throw FlutterError('TestAssetBundle: asset no registrado "$key"');
    }
    return value;
  }
}
