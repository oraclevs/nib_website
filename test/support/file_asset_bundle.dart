import 'dart:io';

import 'package:flutter/services.dart';

/// Tests load the checked source assets without asynchronous engine channels.
class FileAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    // Flutter generates the image-variant manifest in the test asset bundle.
    // Source examples still load from their actual files below.
    if (key == 'AssetManifest.bin') return rootBundle.load(key);
    final bytes = File(key).readAsBytesSync();
    return ByteData.sublistView(bytes);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      File(key).readAsStringSync();
}
