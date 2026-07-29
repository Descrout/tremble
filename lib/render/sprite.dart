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
    final w = r.width * scale;
    final h = r.height * scale;

    if (rotation == 0) {
      return AABB(
        Vec2(position.x - originX * w, position.y - originY * h),
        width: w,
        height: h,
      );
    }

    final ox = r.width * originX;
    final oy = r.height * originY;
    final cosR = cos(rotation);
    final sinR = sin(rotation);

    final l = -ox, rw = r.width - ox;
    final t = -oy, b = r.height - oy;

    final sx = scale, cx = cosR, sx2 = sinR;

    final lc = l * cx, ls = l * sx2;
    final rc = rw * cx, rs = rw * sx2;
    final tc = t * cx, ts = t * sx2;
    final bc = b * cx, bs = b * sx2;

    final p1x = position.x + (lc - ts) * sx;
    final p1y = position.y + (ls + tc) * sx;
    final p2x = position.x + (lc - bs) * sx;
    final p2y = position.y + (ls + bc) * sx;
    final p3x = position.x + (rc - ts) * sx;
    final p3y = position.y + (rs + tc) * sx;
    final p4x = position.x + (rc - bs) * sx;
    final p4y = position.y + (rs + bc) * sx;

    final minX = min(min(p1x, p2x), min(p3x, p4x));
    final maxX = max(max(p1x, p2x), max(p3x, p4x));
    final minY = min(min(p1y, p2y), min(p3y, p4y));
    final maxY = max(max(p1y, p2y), max(p3y, p4y));

    return AABB(
      Vec2(minX, minY),
      width: maxX - minX,
      height: maxY - minY,
    );
  }
}
