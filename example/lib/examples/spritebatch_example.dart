import 'dart:math';

import 'package:flutter/material.dart' hide Animation;
import 'package:tremble/tremble.dart';

class SpritebatchExample extends ScreenController {
  late SpriteBatch batch;
  final sprites = <Sprite>[];
  double timer = 0;

  @override
  Future<void> preload(UpdateCallback progress, VoidCallback done) async {
    batch = await SpriteBatch.fromGdxPacker("assets/sprites.atlas");
    done();
  }

  @override
  void setup(BuildContext context, double width, double height) {
    sprites.addAll([
      Sprite(
        texture: batch.getTexture(Tex.MysteryBlock),
        position: Vec2(width * 0.5 - 200, height * 0.5),
        originX: 0.5,
        originY: 1,
      ),
      Sprite(
        texture: batch.getTexture(Tex.GroundBlock),
        position: Vec2(width * 0.5, height * 0.5),
        originX: 1,
        originY: 1,
      ),
      Animation(
        animations: [batch.getAnimation(Tex.Mario_Big_Run, speed: 8)],
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

// ignore_for_file: constant_identifier_names
////////// Enum for the animations and texture in the atlas.

enum TexType { texture, animation }

enum Tex implements AssetName {
  Brick(TexType.texture),
  Bush1(TexType.texture),
  Bush2(TexType.texture),
  Bush3(TexType.texture),
  Castle(TexType.texture),
  Cloud1(TexType.texture),
  Cloud2(TexType.texture),
  Cloud3(TexType.texture),
  Coin(TexType.texture),
  Coin_Underground(TexType.texture),
  EmptyBlock(TexType.texture),
  Flag(TexType.texture),
  FlagPole(TexType.texture),
  Goomba_Flat(TexType.texture),
  Goomba_Walk(TexType.animation),
  GroundBlock(TexType.texture),
  HardBlock(TexType.texture),
  Hill1(TexType.texture),
  Hill2(TexType.texture),
  Koopa_Shell(TexType.texture),
  Koopa_Walk(TexType.animation),
  MagicMushroom(TexType.texture),
  Mario_Big_Idle(TexType.texture),
  Mario_Big_Jump(TexType.texture),
  Mario_Big_Run(TexType.animation),
  Mario_Big_Slide(TexType.texture),
  Mario_Small_Death(TexType.texture),
  Mario_Small_Idle(TexType.texture),
  Mario_Small_Jump(TexType.texture),
  Mario_Small_Run(TexType.animation),
  Mario_Small_Slide(TexType.texture),
  MysteryBlock(TexType.texture),
  OneUpMushroom(TexType.texture),
  PipeBottom(TexType.texture),
  PipeConnection(TexType.texture),
  PipeTop(TexType.texture),
  Starman(TexType.texture),
  UndergroundBlock(TexType.texture),
  UndergroundBrick(TexType.texture),
  fire(TexType.animation),
  fire_flower(TexType.animation),
  star_anim(TexType.animation);

  final TexType type;
  const Tex(this.type);

  @override
  String get assetName => name;
}
