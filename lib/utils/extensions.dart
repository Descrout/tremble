import 'package:flutter/rendering.dart';
import 'package:tremble/tremble.dart';

extension ColorX on Color {
  Color get inverted {
    return Color.from(
      alpha: 1,
      red: 1 - r,
      green: 1 - g,
      blue: 1 - b,
      colorSpace: colorSpace,
    );
  }
}

extension DoubleX on double {
  double get fract => this - floor();
}

extension RectX on Rect {
  List<Rect> split({required int count, required Axis axis}) {
    const textures = <Rect>[];

    if (axis == Axis.vertical) {
      final increment = height / count;
      for (int i = 0; i < count; i++) {
        final rect = Rect.fromLTWH(left, top + i * increment, width, increment);
        textures.add(rect);
      }
    } else {
      final increment = width / count;
      for (int i = 0; i < count; i++) {
        final rect = Rect.fromLTWH(left + i * increment, top, increment, height);
        textures.add(rect);
      }
    }

    return textures;
  }

  List<Rect> gridByCount(int horizontalCount, int verticalCount) {
    final textures = <Rect>[];

    final incrementW = width / horizontalCount;
    final incrementH = height / verticalCount;

    for (int i = 0; i < horizontalCount; i++) {
      for (int j = 0; j < verticalCount; j++) {
        final rect = Rect.fromLTWH(
          left + i * incrementW,
          top + j * incrementH,
          incrementW,
          incrementH,
        );
        textures.add(rect);
      }
    }

    return textures;
  }

  List<Rect> gridBySize(int cellSize) {
    final textures = <Rect>[];

    final horizontalCount = width ~/ cellSize;
    final verticalCount = height ~/ cellSize;

    for (int i = 0; i < horizontalCount; i++) {
      for (int j = 0; j < verticalCount; j++) {
        final rect = Rect.fromLTWH(
          left + i * cellSize,
          top + j * cellSize,
          cellSize.toDouble(),
          cellSize.toDouble(),
        );
        textures.add(rect);
      }
    }

    return textures;
  }

  AABB get aabb => AABB(Vec2(left, top), width: width, height: height);
}

extension IntGridX on Grid<int> {
  @pragma('vm:prefer-inline')
  void draw(
    Canvas canvas,
    TileMap tileMap, {
    Vec2? position,
    AABB? cullArea,
  }) =>
      tileMap.drawGrid(canvas, this);

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
  void debugDraw(Canvas canvas,
      {Vec2? position,
      AABB? cullArea,
      List<Color> palette = const [
        Color(0xFFFFB74D),
        Color(0xFF64B5F6),
        Color(0xFF81C784),
        Color(0xFFE57373),
        Color(0xFFBA68C8),
        Color(0xFF4DD0E1),
        Color(0xFFFFD54F),
        Color(0xFFA1887F),
      ]}) {
    final paint = Paint();
    forEachDrawArea(
      visit: (screenX, screenY, tile) {
        paint.color = palette[tile % palette.length];
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
    buffer.writeAll(data, ",");
    buffer.write("]");
    return buffer.toString();
  }

  String toJson2d() {
    final buffer = StringBuffer();
    buffer.write("[");
    for (int j = 0; j < height; j++) {
      if (j > 0) buffer.write(",");
      buffer.write("[");
      buffer.writeAll(data.sublist(width * j, width * j + width), ",");
      buffer.write("]");
    }
    buffer.write("]");
    return buffer.toString();
  }
}
