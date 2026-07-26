import 'dart:math';

import 'package:tremble/utils/parametrics.dart';

abstract class MathUtils {
  static Random _rnd = Random();

  static int randInt(int min, int max) {
    return _rnd.nextInt(max - min) + min;
  }

  static double randDouble(double min, double max) {
    return _rnd.nextDouble() * (max - min) + min;
  }

  static T randWeightedTake<T>(List<T> arr, List<double> weights) {
    final total = weights.reduce((a, b) => a + b);
    var roll = _rnd.nextDouble() * total;

    for (var i = 0; i < arr.length; i++) {
      roll -= weights[i];
      if (roll <= 0) {
        weights.removeAt(i);
        return arr.removeAt(i);
      }
    }

    weights.removeLast();
    return arr.removeLast();
  }

  static T randPick<T>(List<T> arr) {
    return arr[_rnd.nextInt(arr.length)];
  }

  static T randWeightedPick<T>(List<T> arr, List<double> weights) {
    final total = weights.reduce((a, b) => a + b);
    var roll = _rnd.nextDouble() * total;

    for (var i = 0; i < arr.length; i++) {
      roll -= weights[i];
      if (roll <= 0) return arr[i];
    }

    return arr.last;
  }

  static T randTake<T>(List<T> arr) {
    return arr.removeAt(_rnd.nextInt(arr.length));
  }

  static bool flipCoin() {
    return _rnd.nextBool();
  }

  static bool flipCoinWith(double prob) {
    return _rnd.nextDouble() < prob;
  }

  static void shuffle<T>(List<T> arr) {
    arr.shuffle(_rnd);
  }

  static void seedRandom(int seed) {
    _rnd = Random(seed);
  }

  @pragma('vm:prefer-inline')
  static double lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @pragma('vm:prefer-inline')
  static double inverseLerp(double a, double b, double v) {
    return (v - a) / (b - a);
  }

  static double remap(double v, double a, double b, double c, double d,
      {ParametricFunc paramteric = Parametrics.linear}) {
    return lerp(c, d, paramteric(inverseLerp(a, b, v)));
  }

  static double moveTowards(
    double current,
    double target,
    double maxDelta,
  ) {
    final delta = target - current;

    if (delta.abs() <= maxDelta) {
      return target;
    }

    return current + delta.sign * maxDelta;
  }

  static double damp(
    double current,
    double target,
    double lambda,
    double deltaTime,
  ) {
    final t = 1 - exp(-lambda * deltaTime);
    return lerp(current, target, t);
  }

  static double constrain(double val, double min, double max) {
    if (val < min) return min;
    if (val > max) return max;
    return val;
  }

  @pragma('vm:prefer-inline')
  static int lcm(int a, int b) => (a * b) ~/ a.gcd(b);

  static double normalizeAngle(double a) {
    a = (a + pi) % (2 * pi);
    if (a < 0) a += 2 * pi;
    return a - pi;
  }

  static double lerpAngle(double from, double to, double t) {
    final diff = normalizeAngle(to - from);
    return from + diff * t;
  }
}
