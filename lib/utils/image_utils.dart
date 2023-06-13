import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ImageUtils {
  static Future<Image?> loadImageFromBytes(Uint8List bytes) async {
    try {
      final codec = await instantiateImageCodec(bytes);
      var frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      debugPrint("loadImageFromBytes error : $_");
      return null;
    }
  }

  static Future<Image?> loadImageFromAssets(String imageAssetPath) async {
    try {
      final ByteData data = await rootBundle.load(imageAssetPath);
      return loadImageFromBytes(data.buffer.asUint8List());
    } catch (_) {
      debugPrint("loadImageFromAssets error : $_");
      return null;
    }
  }

  static Future<Image?> loadImageFromPath(String path) async {
    try {
      final file = File(path);
      return loadImageFromBytes(await file.readAsBytes());
    } catch (_) {
      debugPrint("loadImageFromPath error : $_");
      return null;
    }
  }
}
