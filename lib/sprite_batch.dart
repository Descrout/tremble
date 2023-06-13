import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:tremble/sprite.dart';

class SpriteBatch {
  SpriteBatch({
    required this.atlas,
    required this.textures,
    required this.frames,
  });

  final Image atlas;
  final Map<String, Rect> textures;
  final Map<String, List<Rect>> frames;

  void draw(Canvas canvas, List<Sprite> sprites, [Paint? paint]) {
    final transforms = <RSTransform>[];
    final rects = <Rect>[];
    final colors = <Color>[];

    for (final sprite in sprites) {
      final rect =
          sprite.index != null ? frames[sprite.texture]![sprite.index!] : textures[sprite.texture]!;

      rects.add(rect);

      colors.add(Colors.white.withOpacity(sprite.opacity));

      transforms.add(RSTransform.fromComponents(
        rotation: sprite.rotation,
        scale: 1.0,
        anchorX: rect.width * sprite.originX,
        anchorY: rect.height * sprite.originY,
        translateX: sprite.x,
        translateY: sprite.y,
      ));
    }

    canvas.drawAtlas(
      atlas,
      transforms,
      rects,
      colors,
      BlendMode.srcIn,
      null,
      paint ?? Paint(),
    );
  }
}
