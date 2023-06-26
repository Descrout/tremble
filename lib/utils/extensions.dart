import 'package:flutter/rendering.dart';

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

  List<Rect> grid(int horizontalCount, int verticalCount) {
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
}
