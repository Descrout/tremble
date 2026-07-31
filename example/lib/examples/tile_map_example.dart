import 'dart:ui';

import 'package:flutter/material.dart' show BuildContext, Colors;
import 'package:flutter/services.dart';
import 'package:tremble/tremble.dart';
import 'package:tremble_example/tex_enum.dart';

class TileMapExample extends ScreenController {
  late SpriteBatch batch;
  late final TileMap tileMap;

  final grid = Grid.empty(cellSize: 32, width: 25, height: 17);

  int selectedTile = 0;
  int lastButton = -1;
  double _height = 0;

  final infoText = CanvasText(
      text: "Pick a tile from the left panel.\nLeft click to draw, Right click to remove.");

  @override
  Future<void> preload(UpdateCallback progress, VoidCallback done) async {
    // You can either use SpriteBatch or just load image and split manually for TileMap
    // final image = await ImageUtils.loadImageFromAssets("assets/sprites.png");
    batch = await SpriteBatch.fromGdxPacker("assets/sprites.atlas");
    done();
  }

  @override
  void setup(BuildContext context, double width, double height) {
    _height = height;
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
  }

  @override
  void update(double deltaTime) {}

  @override
  void mousePressed(int pointerID, int button, double mouseX, double mouseY) {
    lastButton = button;

    if (mouseY >= _height - 48) {
      final index = mouseX ~/ 48;
      if (button == 1 && index >= 0 && index < tileMap.tileAreas.length) {
        selectedTile = index;
      }
      return;
    }

    mouseMove(pointerID, mouseX, mouseY);
  }

  @override
  void mouseReleased(int pointerID) {
    lastButton = -1;
  }

  @override
  void mouseMove(int pointerID, double mouseX, double mouseY) {
    if (lastButton == -1 || !grid.inBounds2dScreen(mouseX, mouseY)) return;

    if (lastButton == 1) grid.setTile2dScreen(selectedTile, x: mouseX, y: mouseY);
    if (lastButton == 2) grid.setTile2dScreen(-1, x: mouseX, y: mouseY);
  }

  @override
  void draw(Canvas canvas, Size size) {
    tileMap.drawGrid(canvas, grid);

    canvas.drawLine(
      Offset(0, size.height - 48),
      Offset(size.width, size.height - 48),
      Paint()
        ..color = Colors.green
        ..strokeWidth = 4,
    );

    for (int i = 0; i < tileMap.tileAreas.length; i++) {
      final rect = tileMap.tileAreas[i];
      canvas.drawImageRect(
        tileMap.image,
        rect,
        Rect.fromLTWH(i * 48, size.height - 48, 48, 48),
        TileMap.paint,
      );
    }

    canvas.drawRect(
      Rect.fromLTWH(selectedTile * 48, size.height - 48, 48, 48),
      Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    infoText.draw(canvas, Vec2(size.width / 2 + 20, size.height - 45));
  }

  @override
  void keyDown(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.space) {
      Clipboard.setData(ClipboardData(text: grid.toJson1d()));
    }
  }

  @override
  void dispose() {
    batch.dispose();
  }
}
