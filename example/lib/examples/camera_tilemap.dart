import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' show BuildContext;
import 'package:tremble/tremble.dart';
import 'package:tremble_example/tex_enum.dart';

class CameraTilemap extends ScreenController {
  late SpriteBatch batch;
  late final TileMap tileMap;

  final infoText = CanvasText();
  int actualCount = 0;

  final grid = Grid.empty(cellSize: 32, width: 75, height: 17);
  final camera = Camera();

  @override
  Future<void> preload(UpdateCallback progress, VoidCallback done) async {
    // You can either use SpriteBatch or just load image and split manually for TileMap
    // final image = await ImageUtils.loadImageFromAssets("assets/sprites.png");
    batch = await SpriteBatch.fromGdxPacker("assets/sprites.atlas");
    done();
  }

  @override
  void setup(BuildContext context, double width, double height) {
    tileMap = TileMap(
      tileAreas: [
        batch.getTexture(Tex.groundBlock).rect,
        batch.getTexture(Tex.brick).rect,
        batch.getTexture(Tex.emptyBlock).rect,
        batch.getTexture(Tex.hardBlock).rect,
        batch.getTexture(Tex.mysteryBlock).rect,
        batch.getTexture(Tex.undergroundBlock).rect,
        batch.getTexture(Tex.undergroundBrick).rect,
      ],
      image: batch.image,
      tileScale: 2,
    );

    for (int i = 0; i < grid.length; i++) {
      if (MathUtils.flipCoinWith(0.3)) {
        actualCount++;
        grid.setTile1d(MathUtils.randInt(0, tileMap.tileAreas.length), idx: i);
      }
    }
  }

  double _timer = 0;
  @override
  void update(double deltaTime) {
    _timer += deltaTime * 0.35;
    camera.position.x = MathUtils.remap(sin(_timer), -1, 1, -801, 2401);

    int drawingCount = 0;
    grid.forEachDrawArea(
        visit: (screenX, screenY, tile) => drawingCount++,
        cullArea: camera.aabb(width: 800, height: 600 - 48));
    infoText.text = "Actual Count: $actualCount\nDraw Count: $drawingCount";
  }

  @override
  void draw(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFF5C94FC), BlendMode.src);

    camera.start(canvas);
    tileMap.drawGrid(canvas, grid,
        cullArea: camera.aabb(width: size.width, height: size.height - 48));
    camera.stop(canvas);

    drawBottomPanel(canvas, size);
  }

  void drawBottomPanel(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, size.height - 48, size.width, 48), Paint());
    infoText.draw(canvas, Vec2(24, size.height - 45));
  }

  @override
  void dispose() {
    batch.dispose();
  }
}
