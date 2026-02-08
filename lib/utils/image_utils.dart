import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract class ImageUtils {
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

  static Future<Image> generateFlipped(Image image) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    final p = Paint();

    canvas.drawImage(image, Offset.zero, p);
    canvas.scale(-1, 1);
    canvas.drawImage(image, Offset(-image.width * 2, 0), p);

    final picture = recorder.endRecording();
    return picture.toImage(image.width * 2, image.height);
  }

  static Future<Image> generateMasked(Image image) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    final width = image.width.toDouble();
    final height = image.height.toDouble();

    canvas.drawImage(image, Offset.zero, Paint());

    canvas.drawRect(
      Rect.fromLTWH(0, height, width, height),
      Paint()..color = const Color(0xFFFFFFFF),
    );

    canvas.drawImage(
      image,
      Offset(0, height),
      Paint()..blendMode = BlendMode.dstIn,
    );

    final picture = recorder.endRecording();
    return await picture.toImage(image.width, image.height * 2);
  }

  static Future<File?> saveImage(Image image, String path) async {
    try {
      final byteData = await image.toByteData(format: ImageByteFormat.png);

      if (byteData == null) {
        throw Exception("Failed to convert image to bytes");
      }

      final pngBytes = byteData.buffer.asUint8List();

      return await File(path).writeAsBytes(pngBytes);
    } catch (err) {
      debugPrint("saveImage error : $err");
      return null;
    }
  }
}
