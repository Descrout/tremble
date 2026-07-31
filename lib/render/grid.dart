import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:tremble/physics/aabb.dart';
import 'package:tremble/physics/vec2.dart';
import 'package:tremble/render/tile_map.dart';

class Grid {
  final int cellSize;
  final int width;
  final int height;
  final List<int> _data;

  UnmodifiableListView get data => UnmodifiableListView(_data);
  List<int> clone({bool growable = false}) => List.of(_data, growable: growable);

  int get length => width * height;

  Grid({required this.cellSize, required this.width, required this.height, required List<int> data})
      : assert(data.length == width * height, "Grid data and width*height mismatch"),
        _data = data;

  Grid.empty({required this.cellSize, required this.width, required this.height})
      : _data = List.generate(width * height, (_) => -1);

  Grid.from2d({required this.cellSize, required List<List<int>> data})
      : assert(
            data.isNotEmpty && data[0].isNotEmpty, "2d data array must contain at least 1 element"),
        width = data[0].length,
        height = data.length,
        _data = data.expand((e) => e).toList();

  @pragma('vm:prefer-inline')
  int to1d(int x, int y) => y * width + x;

  @pragma('vm:prefer-inline')
  (int, int) to2d(int idx) => (idx % width, idx ~/ width);

  @pragma('vm:prefer-inline')
  int tileAt2d(int x, int y) => _data[to1d(x, y)];

  @pragma('vm:prefer-inline')
  int tileAt1d(int idx) => _data[idx];

  @pragma('vm:prefer-inline')
  bool inBounds1d(int idx) => idx >= 0 && idx < length;

  @pragma('vm:prefer-inline')
  bool inBounds2d(int x, int y) => x >= 0 && x < width && y >= 0 && y < height;

  @pragma('vm:prefer-inline')
  bool inBounds2dScreen(double x, double y) =>
      x >= 0 && x < width * cellSize && y >= 0 && y < height * cellSize;

  @pragma('vm:prefer-inline')
  void setTile1d(int value, {required int idx}) => _data[idx] = value;

  @pragma('vm:prefer-inline')
  void setTile2d(int value, {required int x, required int y}) => _data[to1d(x, y)] = value;

  @pragma('vm:prefer-inline')
  void setTile2dScreen(int value, {required double x, required double y}) => _data[to1d(
        (x / cellSize).floor(),
        (y / cellSize).floor(),
      )] = value;

  @pragma('vm:prefer-inline')
  (int, int) screenToGrid(double x, double y) => ((x / cellSize).floor(), (y / cellSize).floor());

  // Neighbor has controls
  @pragma('vm:prefer-inline')
  bool hasNeighborLeft(int idx) => idx % width > 0;

  @pragma('vm:prefer-inline')
  bool hasNeighborRight(int idx) => idx % width < width - 1;

  @pragma('vm:prefer-inline')
  bool hasNeighborUp(int idx) => idx >= width;

  @pragma('vm:prefer-inline')
  bool hasNeighborDown(int idx) => idx < length - width;

  // One neighbor tile getters
  @pragma('vm:prefer-inline')
  int? leftNeighborTile(int idx) => hasNeighborLeft(idx) ? _data[idx - 1] : null;

  @pragma('vm:prefer-inline')
  int? rightNeighborTile(int idx) => hasNeighborRight(idx) ? _data[idx + 1] : null;

  @pragma('vm:prefer-inline')
  int? upNeighborTile(int idx) => hasNeighborUp(idx) ? _data[idx - width] : null;

  @pragma('vm:prefer-inline')
  int? downNeighborTile(int idx) => hasNeighborDown(idx) ? _data[idx + width] : null;

  @pragma('vm:prefer-inline')
  int? upLeftNeighborTile(int idx) =>
      hasNeighborUp(idx) && hasNeighborLeft(idx) ? _data[idx - width - 1] : null;

  @pragma('vm:prefer-inline')
  int? upRightNeighborTile(int idx) =>
      hasNeighborUp(idx) && hasNeighborRight(idx) ? _data[idx - width + 1] : null;

  @pragma('vm:prefer-inline')
  int? downLeftNeighborTile(int idx) =>
      hasNeighborDown(idx) && hasNeighborLeft(idx) ? _data[idx + width - 1] : null;

  @pragma('vm:prefer-inline')
  int? downRightNeighborTile(int idx) =>
      hasNeighborDown(idx) && hasNeighborRight(idx) ? _data[idx + width + 1] : null;

  /// Calls [visit] for each 4-connected neighbor index without allocating.
  @pragma('vm:prefer-inline')
  void forEachNeighbor4(int idx, void Function(int neighborIdx) visit) {
    if (hasNeighborUp(idx)) visit(idx - width);
    if (hasNeighborDown(idx)) visit(idx + width);
    if (hasNeighborLeft(idx)) visit(idx - 1);
    if (hasNeighborRight(idx)) visit(idx + 1);
  }

  /// Calls [visit] for each 8-connected neighbor index without allocating.
  @pragma('vm:prefer-inline')
  void forEachNeighbor8(int idx, void Function(int neighborIdx) visit) {
    final up = hasNeighborUp(idx);
    final down = hasNeighborDown(idx);
    final left = hasNeighborLeft(idx);
    final right = hasNeighborRight(idx);
    if (up) visit(idx - width);
    if (down) visit(idx + width);
    if (left) visit(idx - 1);
    if (right) visit(idx + 1);
    if (up && left) visit(idx - width - 1);
    if (up && right) visit(idx - width + 1);
    if (down && left) visit(idx + width - 1);
    if (down && right) visit(idx + width + 1);
  }

  /// 4-connected neighbor tile values. Bounds safe. 1 array allocation.
  List<int> neighborTiles4(int idx) {
    final out = <int>[];
    forEachNeighbor4(idx, (n) => out.add(_data[n]));
    return out;
  }

  /// 8-connected neighbor tile values. Bounds safe. 1 array allocation.
  List<int> neighborTiles8(int idx) {
    final out = <int>[];
    forEachNeighbor8(idx, (n) => out.add(_data[n]));
    return out;
  }

  @pragma('vm:prefer-inline')
  void draw(
    Canvas canvas,
    TileMap tileMap, {
    Vec2? position,
    AABB? cullArea,
  }) =>
      tileMap.drawGrid(canvas, this);

  static List<Color> debugPalette = [
    const Color(0xFFFFB74D),
    const Color(0xFF64B5F6),
    const Color(0xFF81C784),
    const Color(0xFFE57373),
    const Color(0xFFBA68C8),
    const Color(0xFF4DD0E1),
    const Color(0xFFFFD54F),
    const Color(0xFFA1887F),
  ];

  void forEachDrawArea({
    required void Function(double screenX, double screenY, int tile) visit,
    Vec2? position,
    AABB? cullArea,
  }) {
    position ??= Vec2.zero();
    cullArea ??= AABB(
      Vec2.zero(),
      width: (width * cellSize).toDouble(),
      height: (height * cellSize).toDouble(),
    );

    final cullLeft = cullArea.left - position.x;
    final cullRight = cullArea.right - position.x;
    final cullTop = cullArea.top - position.y;
    final cullBottom = cullArea.bottom - position.y;

    final minX = (cullLeft / cellSize).floor();
    final maxX = (cullRight / cellSize).ceil();
    final minY = (cullTop / cellSize).floor();
    final maxY = (cullBottom / cellSize).ceil();

    for (int gy = minY; gy < maxY; gy++) {
      for (int gx = minX; gx < maxX; gx++) {
        if (!inBounds2d(gx, gy)) continue;
        final value = tileAt2d(gx, gy);
        if (value < 0) continue;
        visit(
          position.x + cellSize * gx,
          position.y + cellSize * gy,
          value,
        );
      }
    }
  }

  /// Draws the grid data as colored rects. Tiles with a value smaller than 0 are skipped.
  void debugDraw(
    Canvas canvas, {
    Vec2? position,
    AABB? cullArea,
  }) {
    final paint = Paint();
    forEachDrawArea(
      visit: (screenX, screenY, tile) {
        paint.color = debugPalette[tile % debugPalette.length];
        canvas.drawRect(
          Rect.fromLTWH(
            screenX,
            screenY,
            cellSize.toDouble(),
            cellSize.toDouble(),
          ),
          paint,
        );
      },
      position: position,
      cullArea: cullArea,
    );
  }

  String toJson1d() {
    final buffer = StringBuffer();
    buffer.write("[");
    buffer.writeAll(_data, ",");
    buffer.write("]");
    return buffer.toString();
  }

  String toJson2d() {
    final buffer = StringBuffer();
    buffer.write("[");
    for (int j = 0; j < height; j++) {
      if (j > 0) buffer.write(",");
      buffer.write("[");
      buffer.writeAll(_data.sublist(width * j, width * j + width), ",");
      buffer.write("]");
    }
    buffer.write("]");
    return buffer.toString();
  }
}
