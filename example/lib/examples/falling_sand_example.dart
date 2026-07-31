import 'package:flutter/material.dart';
import 'package:tremble/tremble.dart';

class FallingSandExample extends ScreenController {
  static const int emptyTile = -1;
  static const int sandTile = 0;

  final grid = Grid.empty(cellSize: 8, width: 100, height: 75);

  final mouse = Vec2.zero();
  bool _pressed = false;
  final int _brushRadius = 2;

  late final FixedUpdate fixedUpdate;

  @override
  void setup(BuildContext context, double width, double height) {
    fixedUpdate = FixedUpdate(60, onUpdate: _stepSimulation);
  }

  @override
  void update(double deltaTime) {
    if (_pressed) _spawnSand();
    fixedUpdate.update(deltaTime);
  }

  void _spawnSand() {
    final (gx, gy) = grid.screenToGrid(mouse.x, mouse.y);
    for (int dy = -_brushRadius; dy <= _brushRadius; dy++) {
      for (int dx = -_brushRadius; dx <= _brushRadius; dx++) {
        final x = gx + dx;
        final y = gy + dy;
        if (!grid.inBounds2d(x, y)) continue;
        if (grid.tileAt2d(x, y) != emptyTile) continue;
        grid.setTile2d(sandTile, x: x, y: y);
      }
    }
  }

  void _stepSimulation(_) {
    final g = grid;
    final w = g.width;
    final h = g.height;

    for (int gy = h - 1; gy >= 0; gy--) {
      for (int gx = 0; gx < w; gx++) {
        final idx = g.to1d(gx, gy);
        if (g.tileAt1d(idx) != sandTile) continue;

        final belowY = gy + 1;
        if (belowY >= h) continue;
        final belowRow = belowY * w;

        if (g.tileAt1d(belowRow + gx) == emptyTile) {
          g.setTile1d(sandTile, idx: belowRow + gx);
          g.setTile1d(emptyTile, idx: idx);
          continue;
        }

        final canLeft = gx > 0 && g.tileAt1d(belowRow + gx - 1) == emptyTile;
        final canRight = gx < w - 1 && g.tileAt1d(belowRow + gx + 1) == emptyTile;

        if (canLeft && canRight) {
          final target = belowRow + (gx + (MathUtils.flipCoin() ? -1 : 1));
          g.setTile1d(sandTile, idx: target);
          g.setTile1d(emptyTile, idx: idx);
        } else if (canLeft) {
          g.setTile1d(sandTile, idx: belowRow + gx - 1);
          g.setTile1d(emptyTile, idx: idx);
        } else if (canRight) {
          g.setTile1d(sandTile, idx: belowRow + gx + 1);
          g.setTile1d(emptyTile, idx: idx);
        }
      }
    }
  }

  @override
  void draw(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFF0d0d14), BlendMode.src);
    grid.debugDraw(canvas);
  }

  @override
  void mousePressed(int pointerID, int button, double mouseX, double mouseY) {
    mouse.set(mouseX, mouseY);
    _pressed = true;
    _spawnSand();
  }

  @override
  void mouseMove(int pointerID, double mouseX, double mouseY) {
    mouse.set(mouseX, mouseY);
    if (_pressed) _spawnSand();
  }

  @override
  void mouseReleased(int pointerID) {
    _pressed = false;
  }

  @override
  void dispose() {}
}
