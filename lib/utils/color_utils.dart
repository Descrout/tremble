import 'package:flutter/rendering.dart';
import 'package:tremble/utils/math_utils.dart';

enum ColorMood { bright, pastel, dark }

abstract class ColorUtils {
  static Color randomColor(ColorMood mood, {double opacity = 1.0}) =>
      ColorUtils.randomHSV(mood, opacity: opacity).toColor();

  static HSVColor randomHSV(ColorMood mood, {double opacity = 1.0}) {
    final h = MathUtils.randDouble(0, 360);

    late final double s;
    late final double v;

    switch (mood) {
      case ColorMood.bright:
        s = MathUtils.randDouble(0.75, 1.0);
        v = MathUtils.randDouble(0.8, 1.0);
        break;

      case ColorMood.pastel:
        s = MathUtils.randDouble(0.25, 0.45);
        v = MathUtils.randDouble(0.85, 0.95);
        break;

      case ColorMood.dark:
        s = MathUtils.randDouble(0.4, 0.7);
        v = MathUtils.randDouble(0.15, 0.35);
        break;
    }

    return HSVColor.fromAHSV(
      opacity.clamp(0.0, 1.0),
      h,
      s,
      v,
    );
  }
}
