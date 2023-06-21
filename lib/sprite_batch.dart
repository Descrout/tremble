import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:tremble/tremble.dart';

class SpriteBatch {
  SpriteBatch({
    required this.image,
    required this.textures,
    required this.frames,
  });

  final Image image;
  final Map<String, Rect> textures;
  final Map<String, List<Rect>> frames;

  static Future<SpriteBatch> fromGdxPacker(String path) async {
    (int, int) getTupple(String data) {
      final split = data.split(', ');
      return (int.parse(split[0]), int.parse(split[1]));
    }

    ({String name, Rect rect, int? index}) getInfo(List<String> lines, int idx) {
      late Size size;
      late Offset offset;
      int? index;

      for (int i = 1; i < 7; i++) {
        final [tag, data] = lines[idx + i].trim().split(': ');
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

    return SpriteBatch(
      image: image!,
      textures: textures,
      frames: framesMap.map((key, value) => MapEntry(key, value.values.toList())),
    );
  }

  Rect getTexture(String key) {
    return textures[key]!;
  }

  MapEntry<String, AnimationData> getAnimation(
    String key, {
    required double speed,
    bool loop = true,
  }) =>
      MapEntry(key, AnimationData(frames: frames[key]!, speed: speed, loop: loop));

  void draw(Canvas canvas, List<Sprite> sprites, [Paint? paint]) {
    final transforms = <RSTransform>[];
    final rects = <Rect>[];
    final colors = <Color>[];

    for (final sprite in sprites) {
      rects.add(sprite.texture);

      colors.add(Colors.white.withOpacity(sprite.opacity));

      transforms.add(RSTransform.fromComponents(
        rotation: sprite.rotation,
        scale: 1.0,
        anchorX: sprite.texture.width * sprite.originX,
        anchorY: sprite.texture.height * sprite.originY,
        translateX: sprite.x,
        translateY: sprite.y,
      ));
    }

    canvas.drawAtlas(
      image,
      transforms,
      rects,
      colors,
      BlendMode.srcIn,
      null,
      paint ?? Paint(),
    );
  }

  void dispose() {
    image.dispose();
  }
}
