import 'dart:math';

import 'package:flutter/material.dart' hide Animation;
import 'package:tremble/tremble.dart';
import 'package:tremble_example/tex_enum.dart';

class SpritebatchExample extends ScreenController {
  late final SpriteBatch batch;
  final sprites = <Sprite>[];
  double timer = 0;

  @override
  Future<void> preload(UpdateCallback progress, VoidCallback done) async {
    batch = await SpriteBatch.fromGdxPacker("assets/sprites.atlas");

    // You can get the enum string like this or just write to tex_enum.dart directly :)
    //await Clipboard.setData(ClipboardData(text: batch.getEnum()));

    done();
  }

  @override
  void setup(BuildContext context, double width, double height) {
    sprites.addAll([
      Sprite(
        texture: batch.getTexture(Tex.mysteryBlock),
        position: Vec2(width * 0.5 - 200, height * 0.5),
        originX: 0.5,
        originY: 1,
      ),
      Sprite(
        texture: batch.getTexture(Tex.groundBlock),
        position: Vec2(width * 0.5, height * 0.5),
        originX: 1,
        originY: 1,
      ),
      Animation(
        animations: [batch.getAnimation(Tex.marioBigRun, speed: 8)],
        position: Vec2(width * 0.5 + 200, height * 0.5),
      )
    ]);
  }

  @override
  void update(double deltaTime) {
    timer += deltaTime;

    for (int i = 0; i < sprites.length; i++) {
      final spr = sprites[i];
      final sw = (sin(timer + i) + 1) * 0.5;

      spr.rotation = sw * pi;
      spr.scale = sw + 3;
      spr.opacity = (sw * 205).toInt() + 50;

      if (spr is Animation) spr.update(deltaTime);
    }
  }

  @override
  void draw(Canvas canvas, Size size) {
    Shape.paint.style = PaintingStyle.stroke;
    Shape.paint.color = Colors.white;
    canvas.drawLine(
        Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), Shape.paint);
    batch.draw(canvas, sprites);

    for (final spr in sprites) {
      spr.aabb.draw(canvas, Colors.transparent, true);
      Shape.paint.style = PaintingStyle.fill;
      canvas.drawCircle(spr.position.offset(), 4, Shape.paint);
    }
  }

  @override
  void dispose() {
    batch.dispose();
  }
}
