class MathUtils {
  double lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  double inverseLerp(double a, double b, double v) {
    return (v - a) / (b - a);
  }

  double remap(double v, double a, double b, double c, double d) {
    return lerp(c, d, inverseLerp(a, b, v));
  }

  double constrain(double val, double min, double max) {
    if (val < min) return min;
    if (val > max) return max;
    return val;
  }

  int lcm(int a, int b) => (a * b) ~/ a.gcd(b);
}
