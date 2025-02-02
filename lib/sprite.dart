import 'package:flutter/material.dart';

class Sprite {
  Sprite({
    required this.texture,
    required this.x,
    required this.y,
    this.originX = 0.5,
    this.originY = 0.5,
    this.opacity = 255,
    this.scale = 1.0,
    this.rotation = 0,
    this.flip = false,
    this.tint = Colors.white,
  });

  Sprite copy() {
    return Sprite(
      texture: Rect.fromLTWH(texture.left, texture.top, texture.width, texture.height),
      x: x,
      y: y,
      originX: originX,
      originY: originY,
      opacity: opacity,
      scale: scale,
      rotation: rotation,
      flip: flip,
    );
  }

  Rect texture;

  double x;
  double y;

  double originX;
  double originY;

  int opacity;
  double rotation;
  double scale;

  bool flip;

  Color tint;

  RSTransform get tranform => RSTransform.fromComponents(
        rotation: rotation,
        scale: scale,
        anchorX: texture.width * originX,
        anchorY: texture.height * originY,
        translateX: x,
        translateY: y,
      );
}
