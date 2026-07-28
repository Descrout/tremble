import 'package:flutter/material.dart';
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
}
