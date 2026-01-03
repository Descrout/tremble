import 'dart:math';

abstract class MathUtils {
  static Random _rnd = Random();

  static int randInt(int min, int max) {
    return _rnd.nextInt(max - min) + min;
  }

  static double randDouble(double min, double max) {
    return _rnd.nextDouble() * (max - min) + min;
  }

  static T randPick<T>(List<T> arr) {
    return arr[_rnd.nextInt(arr.length)];
  }

  static bool flipCoin() {
    return _rnd.nextBool();
  }

  static void shuffle<T>(List<T> arr) {
    arr.shuffle(_rnd);
  }

  static void seedRandom(int seed) {
    _rnd = Random(seed);
  }

  static double lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  static double inverseLerp(double a, double b, double v) {
    return (v - a) / (b - a);
  }

  static double remap(double v, double a, double b, double c, double d) {
    return lerp(c, d, inverseLerp(a, b, v));
  }

  static double constrain(double val, double min, double max) {
    if (val < min) return min;
    if (val > max) return max;
    return val;
  }

  static int lcm(int a, int b) => (a * b) ~/ a.gcd(b);
}
