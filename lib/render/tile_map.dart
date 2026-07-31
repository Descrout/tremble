import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:tremble/physics/aabb.dart';
import 'package:tremble/physics/vec2.dart';
import 'package:tremble/render/grid.dart';

class TileMap {
  final List<Rect> tileAreas;
  final Image image;
  double tileScale;

  TileMap({required this.tileAreas, required this.image, this.tileScale = 1.0});

  //Reusable buffers
  Float32List _rects = Float32List(0);
  Float32List _transforms = Float32List(0);
  Int32List _colors = Int32List(0);

  static final paint = Paint()
    ..filterQuality = FilterQuality.none
    ..isAntiAlias = false;

  void _ensureCapacity(int count) {
    final needed = count * 4;
    if (_rects.length < needed) {
      final newSize = max(needed, (_rects.length * 1.5).round());
      _rects = Float32List(newSize);
      _transforms = Float32List(newSize);
      _colors = Int32List(newSize ~/ 4);
    }
  }

  void drawGrid(
    Canvas canvas,
    Grid grid, {
    Vec2? position,
    AABB? cullArea,
  }) {
    position ??= Vec2.zero();
    cullArea ??= AABB(
      Vec2.zero(),
      width: (grid.width * grid.cellSize).toDouble(),
      height: (grid.height * grid.cellSize).toDouble(),
    );

    final cullLeft = cullArea.left - position.x;
    final cullRight = cullArea.right - position.x;
    final cullTop = cullArea.top - position.y;
    final cullBottom = cullArea.bottom - position.y;

    int minX = cullLeft ~/ grid.cellSize;
    int maxX = cullRight ~/ grid.cellSize + 1;

    int minY = cullTop ~/ grid.cellSize;
    int maxY = cullBottom ~/ grid.cellSize + 1;

    _ensureCapacity((maxX - minX) * (maxY - minY));

    int i = 0;

    for (int gy = minY; gy <= maxY; gy++) {
      for (int gx = minX; gx < maxX; gx++) {
        if (!grid.inBounds2d(gx, gy)) continue;
        final idx = gy * grid.width + gx;
        final areaIdx = grid.tileAt1d(idx);
        if (areaIdx < 0 || areaIdx >= tileAreas.length) continue;

        final rect = tileAreas[areaIdx];

        final ri = i * 4;
        _rects[ri + 0] = rect.left;
        _rects[ri + 1] = rect.top;
        _rects[ri + 2] = rect.right;
        _rects[ri + 3] = rect.bottom;

        final ti = i * 4;
        _transforms[ti + 0] = tileScale;
        _transforms[ti + 1] = 0;
        _transforms[ti + 2] = position.x + grid.cellSize * gx;
        _transforms[ti + 3] = position.y + grid.cellSize * gy;

        _colors[i] = 0xFFFFFFFF;
        i++;
      }
    }

    canvas.drawRawAtlas(
      image,
      Float32List.sublistView(_transforms, 0, i * 4),
      Float32List.sublistView(_rects, 0, i * 4),
      Int32List.sublistView(_colors, 0, i),
      BlendMode.modulate,
      null,
      paint,
    );
  }

  void drawGrids(
    Canvas canvas,
    List<Grid> grids, {
    Vec2? position,
    AABB? cullArea,
  }) {
    if (grids.isEmpty) return;
    position ??= Vec2.zero();
    cullArea ??= AABB(
      Vec2.zero(),
      width: (grids[0].width * grids[0].cellSize).toDouble(),
      height: (grids[0].height * grids[0].cellSize).toDouble(),
    );

    final cullLeft = cullArea.left - position.x;
    final cullRight = cullArea.right - position.x;
    final cullTop = cullArea.top - position.y;
    final cullBottom = cullArea.bottom - position.y;

    int minX = cullLeft ~/ grids[0].cellSize;
    int maxX = cullRight ~/ grids[0].cellSize + 1;

    int minY = cullTop ~/ grids[0].cellSize;
    int maxY = cullBottom ~/ grids[0].cellSize + 1;

    _ensureCapacity((maxX - minX) * (maxY - minY) * grids.length);

    int i = 0;

    for (int gy = minY; gy <= maxY; gy++) {
      for (int gx = minX; gx < maxX; gx++) {
        for (final grid in grids) {
          if (!grid.inBounds2d(gx, gy)) continue;
          final idx = gy * grid.width + gx;
          final areaIdx = grid.tileAt1d(idx);
          if (areaIdx < 0 || areaIdx >= tileAreas.length) continue;

          final rect = tileAreas[areaIdx];

          final ri = i * 4;
          _rects[ri + 0] = rect.left;
          _rects[ri + 1] = rect.top;
          _rects[ri + 2] = rect.right;
          _rects[ri + 3] = rect.bottom;

          final ti = i * 4;
          _transforms[ti + 0] = tileScale;
          _transforms[ti + 1] = 0;
          _transforms[ti + 2] = position.x + grid.cellSize * gx;
          _transforms[ti + 3] = position.y + grid.cellSize * gy;

          _colors[i] = 0xFFFFFFFF;
          i++;
        }
      }
    }

    canvas.drawRawAtlas(
      image,
      Float32List.sublistView(_transforms, 0, i * 4),
      Float32List.sublistView(_rects, 0, i * 4),
      Int32List.sublistView(_colors, 0, i),
      BlendMode.modulate,
      null,
      paint,
    );
  }
}
