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
