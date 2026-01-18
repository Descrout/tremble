typedef ParametricFunc = double Function(double);

abstract class Parametrics {
  @pragma('vm:prefer-inline')
  static double linear(double t) => t;

  static double mix(ParametricFunc f1, ParametricFunc f2, double t, double blend) =>
      (1 - blend) * f1(t) + blend * f2(t);

  @pragma('vm:prefer-inline')
  static double smoothStart2(double t) => t * t;

  @pragma('vm:prefer-inline')
  static double smoothStart3(double t) => t * t * t;

  @pragma('vm:prefer-inline')
  static double smoothStart4(double t) => t * t * t * t;

  static double smoothStop2(double t) => 1 - smoothStart2(1 - t);

  static double smoothStop3(double t) => 1 - smoothStart3(1 - t);

  static double smoothStop4(double t) => 1 - smoothStart4(1 - t);

  static double smoothStep2(double t) => mix(smoothStart2, smoothStop2, t, t);

  static double smoothStep3(double t) => mix(smoothStart3, smoothStop3, t, t);

  static double smoothStep4(double t) => mix(smoothStart4, smoothStop4, t, t);

  @pragma('vm:prefer-inline')
  static double arch2(double t) => t * (1 - t);

  static double bellcurve6(double t) => smoothStart3(t) * smoothStop3(t);

  @pragma('vm:prefer-inline')
  static double elasticStart(double t, [double s = 1.70158]) {
    return t * t * ((s + 1) * t - s);
  }

  @pragma('vm:prefer-inline')
  static double elasticStop(double t, [double s = 1.70158]) {
    t -= 1;
    return t * t * ((s + 1) * t + s) + 1;
  }

  static double elasticStep(double t, [double s = 1.70158]) {
    if (t < 0.5) {
      return 0.5 * elasticStart(t * 2, s);
    } else {
      return 0.5 * elasticStop(t * 2 - 1, s) + 0.5;
    }
  }
}
