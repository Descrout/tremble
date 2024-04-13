import 'dart:collection';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:tremble/tremble.dart';

class SpriteBatch {
  SpriteBatch._({
    required this.image,
    required this.textures,
    required this.frames,
  });

  final Image image;
  final Map<String, Rect> textures;
  final Map<String, List<Rect>> frames;
  static final Paint _emptyPaint = Paint()
    ..filterQuality = FilterQuality.none
    ..isAntiAlias = false;

  static Future<SpriteBatch> custom({
    required Image image,
    required Map<String, Rect> textures,
    required Map<String, List<Rect>> frames,
    bool flippable = false,
    Paint? flipPaint,
  }) async {
    return SpriteBatch._(
      image: flippable ? await ImageUtils.generateFlipped(image, flipPaint ?? _emptyPaint) : image,
      textures: textures,
      frames: frames,
    );
  }

  static Future<SpriteBatch> fromGdxPacker(String path,
      {bool flippable = false, Paint? flipPaint}) async {
    Rect getRect(String data) {
      final split = data.split(',');
      return Rect.fromLTWH(
        double.parse(split[0]),
        double.parse(split[1]),
        double.parse(split[2]),
        double.parse(split[3]),
      );
    }

    final atlas = await rootBundle.loadString(path);

    final textures = <String, Rect>{};
    final framesMap = <String, SplayTreeMap<int, Rect>>{};
    final lines = atlas.split('\n');

    int i = 3;

    while (i < lines.length && lines[i] != "") {
      final tempValues = <String, String>{};
      final name = lines[i];
      i++;
      while (i < lines.length && lines[i].contains(":")) {
        final splitted = lines[i].split(":");
        tempValues[splitted[0]] = splitted[1];
        i++;
      }
      if (tempValues.containsKey("index")) {
        //animation
        if (!framesMap.containsKey(name)) framesMap[name] = SplayTreeMap<int, Rect>();
        framesMap[name]![int.parse(tempValues["index"]!)] = getRect(tempValues["bounds"]!);
      } else {
        //texture
        textures[name] = getRect(tempValues["bounds"]!);
      }
    }

    final pathSplit = path.split("/");
    pathSplit.removeLast();
    pathSplit.add(lines[0]);
    final image = await ImageUtils.loadImageFromAssets(pathSplit.join("/"));
    assert(image != null, "Batch image could not be loaded !");

    return SpriteBatch._(
      image:
          flippable ? await ImageUtils.generateFlipped(image!, flipPaint ?? _emptyPaint) : image!,
      textures: textures,
      frames: framesMap.map((key, value) => MapEntry(key, value.values.toList())),
    );
  }

  static Future<SpriteBatch> fromOldGdxPacker(String path,
      {bool flippable = false, Paint? flipPaint}) async {
    (int, int) getTupple(String data) {
      final split = data.split(',');
      return (int.parse(split[0]), int.parse(split[1]));
    }

    ({String name, Rect rect, int? index}) getInfo(List<String> lines, int idx) {
      late Size size;
      late Offset offset;
      int? index;

      for (int i = 1; i < 7; i++) {
        final [tag, data] = lines[idx + i].trim().split(':');
        switch (tag) {
          case "xy":
            final pos = getTupple(data);
            offset = Offset(pos.$1.toDouble(), pos.$2.toDouble());
            break;
          case "size":
            final wh = getTupple(data);
            size = Size(wh.$1.toDouble(), wh.$2.toDouble());
            break;
          case "index":
            if (data != "-1") {
              index = int.parse(data);
            }
            break;
        }
      }

      return (name: lines[idx].trim(), rect: offset & size, index: index);
    }

    final atlas = await rootBundle.loadString(path);

    final textures = <String, Rect>{};
    final framesMap = <String, SplayTreeMap<int, Rect>>{};
    final lines = atlas.split('\n');

    for (int i = 6; i < lines.length - 1; i += 7) {
      final info = getInfo(lines, i);
      if (info.index != null) {
        if (!framesMap.containsKey(info.name)) framesMap[info.name] = SplayTreeMap<int, Rect>();
        framesMap[info.name]![info.index!] = info.rect;
      } else {
        textures[info.name] = info.rect;
      }
    }

    final pathSplit = path.split("/");
    pathSplit.removeLast();
    pathSplit.add(lines[1]);

    final image = await ImageUtils.loadImageFromAssets(pathSplit.join("/"));
    assert(image != null, "Batch image could not be loaded !");

    return SpriteBatch._(
      image:
          flippable ? await ImageUtils.generateFlipped(image!, flipPaint ?? _emptyPaint) : image!,
      textures: textures,
      frames: framesMap.map((key, value) => MapEntry(key, value.values.toList())),
    );
  }

  Rect getTexture(String key) {
    return textures[key]!;
  }

  AnimationData getAnimation(
    String key, {
    required double speed,
    bool loop = true,
  }) =>
      AnimationData(key: key, frames: frames[key]!, speed: speed, loop: loop);

  void draw(Canvas canvas, Iterable<Sprite> sprites, [Paint? paint]) {
    final transforms = <RSTransform>[];
    final rects = <Rect>[];
    final colors = <Color>[];

    for (final sprite in sprites) {
      rects.add(sprite.flip
          ? Rect.fromLTWH(
              image.width - sprite.texture.right,
              sprite.texture.top,
              sprite.texture.width,
              sprite.texture.height,
            )
          : sprite.texture);

      colors.add(sprite.tint.withOpacity(sprite.opacity));

      transforms.add(sprite.tranform);
    }

    canvas.drawAtlas(
      image,
      transforms,
      rects,
      colors,
      BlendMode.modulate,
      null,
      paint ?? _emptyPaint,
    );
  }

  void dispose() {
    image.dispose();
  }
}
