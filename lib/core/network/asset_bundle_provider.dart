import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider del [AssetBundle] usado por los datasources mock que leen JSON
/// desde `assets/`. Default: `rootBundle` (producción). En tests, overridear
/// con `TestAssetBundle` para inyectar JSONs sintéticos sin tocar disco.
final assetBundleProvider = Provider<AssetBundle>((_) => rootBundle);
