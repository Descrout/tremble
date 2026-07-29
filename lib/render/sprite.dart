import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tremble/physics/aabb.dart';
import 'package:tremble/physics/vec2.dart';
import 'package:tremble/render/tex_area.dart';

class Sprite {
  TexArea texture;

  Vec2 position;

  double originX;
  double originY;

  int opacity;
  double rotation;
  double scale;

  Color tint;

  bool flip;
  bool mask;

  Sprite({
    required this.texture,
    required this.position,
    this.originX = 0.5,
    this.originY = 0.5,
    this.opacity = 255,
    this.scale = 1.0,
    this.rotation = 0,
    this.flip = false,
    this.mask = false,
    this.tint = Colors.white,
  });

  void setFrom(Sprite other) {
    texture = other.texture;
    position.setFrom(other.position);
    originX = other.originX;
    originY = other.originY;
    opacity = other.opacity;
    rotation = other.rotation;
    scale = other.scale;
    tint = other.tint;
    flip = other.flip;
    mask = other.mask;
  }

  Sprite copy() {
    return Sprite(
      texture: texture.copy(),
      position: position.clone(),
      originX: originX,
      originY: originY,
      opacity: opacity,
      scale: scale,
      rotation: rotation,
      flip: flip,
      mask: mask,
    );
  }

  AABB get aabb {
    final r = texture.rect;

    if (rotation == 0) {
      final w = r.width * scale;
      final h = r.height * scale;

      return AABB(
        Vec2(
          position.x - originX * w,
          position.y - originY * h,
        ),
        width: w,
        height: h,
      );
    }

    final anchorX = r.width * originX;
    final anchorY = r.height * originY;

    final dx1 = r.left - anchorX;
    final dx2 = r.right - anchorX;
    final dy1 = r.top - anchorY;
    final dy2 = r.bottom - anchorY;

    final scos = cos(rotation) * scale;
    final ssin = sin(rotation) * scale;

    // px = position.x + scos*dx - ssin*dy  ->  {ax1,ax2} - {by1,by2}
    // py = position.y + ssin*dx + scos*dy  ->  {cy1,cy2} + {ey1,ey2}
    final ax1 = scos * dx1, ax2 = scos * dx2;
    final by1 = ssin * dy1, by2 = ssin * dy2;
    final cy1 = ssin * dx1, cy2 = ssin * dx2;
    final ey1 = scos * dy1, ey2 = scos * dy2;

    final axLess = ax1 < ax2;
    final minAx = axLess ? ax1 : ax2;
    final maxAx = axLess ? ax2 : ax1;

    final byLess = by1 < by2;
    final minBy = byLess ? by1 : by2;
    final maxBy = byLess ? by2 : by1;

    final cyLess = cy1 < cy2;
    final minCy = cyLess ? cy1 : cy2;
    final maxCy = cyLess ? cy2 : cy1;

    final eyLess = ey1 < ey2;
    final minEy = eyLess ? ey1 : ey2;
    final maxEy = eyLess ? ey2 : ey1;

    final minX = position.x + minAx - maxBy;
    final maxX = position.x + maxAx - minBy;
    final minY = position.y + minCy + minEy;
    final maxY = position.y + maxCy + maxEy;

    return AABB(
      Vec2(minX, minY),
      width: maxX - minX,
      height: maxY - minY,
    );
  }
}
