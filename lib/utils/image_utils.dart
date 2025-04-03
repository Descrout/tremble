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
    } catch (err) {
      debugPrint("loadImageFromBytes error : $err");
      return null;
    }
  }

  static Future<Image?> loadImageFromAssets(String imageAssetPath) async {
    try {
      final ByteData data = await rootBundle.load(imageAssetPath);
      return loadImageFromBytes(data.buffer.asUint8List());
    } catch (err) {
      debugPrint("loadImageFromAssets error : $err");
      return null;
    }
  }

  static Future<Image?> loadImageFromPath(String path) async {
    try {
      final file = File(path);
      return loadImageFromBytes(await file.readAsBytes());
    } catch (err) {
      debugPrint("loadImageFromPath error : $err");
      return null;
    }
  }

  static Future<Image> generateFlipped(Image image, [Paint? paint]) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    final p = paint ?? Paint();

    canvas.drawImage(image, Offset.zero, p);
    canvas.scale(-1, 1);
    canvas.drawImage(image, Offset(-image.width * 2, 0), p);

    final picture = recorder.endRecording();
    return picture.toImage(image.width * 2, image.height);
  }
}
