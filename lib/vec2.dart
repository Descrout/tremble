import 'dart:math';

class Vec2 {
  double x;
  double y;

  // Constructors
  Vec2(this.x, this.y);

  Vec2.zero()
      : x = 0,
        y = 0;

  Vec2.one()
      : x = 1,
        y = 1;

  Vec2.fromAngle(double angle, [double magnitude = 1.0])
      : x = magnitude * cos(angle),
        y = magnitude * sin(angle);

  Vec2.copy(Vec2 other)
      : x = other.x,
        y = other.y;

  // Properties
  double get magnitude => sqrt(x * x + y * y);

  double get magnitudeSquared => x * x + y * y;

  double get angle => atan2(y, x);

  bool get isZero => x == 0 && y == 0;

  // Instance methods
  Vec2 normalized() {
    final mag = magnitude;
    if (mag == 0) return Vec2.zero();
    return Vec2(x / mag, y / mag);
  }

  void normalize() {
    final mag = magnitude;
    if (mag != 0) {
      x /= mag;
      y /= mag;
    }
  }

  Vec2 clamped(double maxLength) {
    final mag = magnitude;
    if (mag > maxLength) {
      final scale = maxLength / mag;
      return Vec2(x * scale, y * scale);
    }
    return Vec2.copy(this);
  }

  void clamp(double maxLength) {
    final mag = magnitude;
    if (mag > maxLength) {
      final scale = maxLength / mag;
      x *= scale;
      y *= scale;
    }
  }

  double distanceTo(Vec2 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }

  double distanceSquaredTo(Vec2 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return dx * dx + dy * dy;
  }

  double dot(Vec2 other) => x * other.x + y * other.y;

  double cross(Vec2 other) => x * other.y - y * other.x;

  Vec2 rotated(double angle) {
    final ccos = cos(angle);
    final ssin = sin(angle);
    return Vec2(
      x * ccos - y * ssin,
      x * ssin + y * ccos,
    );
  }

  void rotate(double angle) {
    final ccos = cos(angle);
    final ssin = sin(angle);
    final newX = x * ccos - y * ssin;
    final newY = x * ssin + y * ccos;
    x = newX;
    y = newY;
  }

  Vec2 lerp(Vec2 other, double t) {
    return Vec2(
      x + (other.x - x) * t,
      y + (other.y - y) * t,
    );
  }

  Vec2 reflected(Vec2 normal) {
    final d = 2 * dot(normal);
    return Vec2(x - d * normal.x, y - d * normal.y);
  }

  void reflect(Vec2 normal) {
    final d = 2 * dot(normal);
    x -= d * normal.x;
    y -= d * normal.y;
  }

  // Operator overloading
  Vec2 operator +(Object other) {
    if (other is Vec2) {
      return Vec2(x + other.x, y + other.y);
    } else if (other is num) {
      return Vec2(x + other, y + other);
    }
    throw ArgumentError('Invalid operand type for +');
  }

  Vec2 operator -(Object other) {
    if (other is Vec2) {
      return Vec2(x - other.x, y - other.y);
    } else if (other is num) {
      return Vec2(x - other, y - other);
    }
    throw ArgumentError('Invalid operand type for -');
  }

  Vec2 operator *(Object other) {
    if (other is Vec2) {
      return Vec2(x * other.x, y * other.y);
    } else if (other is num) {
      return Vec2(x * other, y * other);
    }
    throw ArgumentError('Invalid operand type for *');
  }

  Vec2 operator /(Object other) {
    if (other is Vec2) {
      return Vec2(x / other.x, y / other.y);
    } else if (other is num) {
      return Vec2(x / other, y / other);
    }
    throw ArgumentError('Invalid operand type for /');
  }

  Vec2 operator -() => Vec2(-x, -y);

  double operator [](int index) {
    switch (index) {
      case 0:
        return x;
      case 1:
        return y;
      default:
        throw RangeError.index(index, [x, y], 'index');
    }
  }

  void operator []=(int index, double value) {
    switch (index) {
      case 0:
        x = value;
        break;
      case 1:
        y = value;
        break;
      default:
        throw RangeError.index(index, [x, y], 'index');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vec2 && x == other.x && y == other.y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  // Static methods
  static Vec2 add(Vec2 a, Vec2 b) {
    return Vec2(a.x + b.x, a.y + b.y);
  }

  static Vec2 subtract(Vec2 a, Vec2 b) {
    return Vec2(a.x - b.x, a.y - b.y);
  }

  static Vec2 multiply(Vec2 a, Vec2 b) {
    return Vec2(a.x * b.x, a.y * b.y);
  }

  static Vec2 divide(Vec2 a, Vec2 b) {
    return Vec2(a.x / b.x, a.y / b.y);
  }

  static Vec2 scale(Vec2 v, double scalar) {
    return Vec2(v.x * scalar, v.y * scalar);
  }

  static double dotBetween(Vec2 a, Vec2 b) {
    return a.x * b.x + a.y * b.y;
  }

  static double crossBetween(Vec2 a, Vec2 b) {
    return a.x * b.y - a.y * b.x;
  }

  static double distance(Vec2 a, Vec2 b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
  }

  static double distanceSquared(Vec2 a, Vec2 b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return dx * dx + dy * dy;
  }

  static Vec2 lerpBetween(Vec2 a, Vec2 b, double t) {
    return Vec2(
      a.x + (b.x - a.x) * t,
      a.y + (b.y - a.y) * t,
    );
  }

  static Vec2 min(Vec2 a, Vec2 b) {
    return Vec2(
      a.x < b.x ? a.x : b.x,
      a.y < b.y ? a.y : b.y,
    );
  }

  static Vec2 max(Vec2 a, Vec2 b) {
    return Vec2(
      a.x > b.x ? a.x : b.x,
      a.y > b.y ? a.y : b.y,
    );
  }

  static Vec2 clampMagnitude(Vec2 v, double maxLength) {
    final mag = v.magnitude;
    if (mag > maxLength) {
      final scale = maxLength / mag;
      return Vec2(v.x * scale, v.y * scale);
    }
    return Vec2.copy(v);
  }

  static double angleBetween(Vec2 a, Vec2 b) {
    final dotProduct = dotBetween(a, b);
    final magnitudes = a.magnitude * b.magnitude;
    if (magnitudes == 0) return 0;
    return acos((dotProduct / magnitudes).clamp(-1.0, 1.0));
  }

  static Vec2 reflectBetween(Vec2 direction, Vec2 normal) {
    final d = 2 * dotBetween(direction, normal);
    return Vec2(
      direction.x - d * normal.x,
      direction.y - d * normal.y,
    );
  }

  // Utility
  Vec2 clone() => Vec2(x, y);

  void set(double newX, double newY) {
    x = newX;
    y = newY;
  }

  void setFrom(Vec2 other) {
    x = other.x;
    y = other.y;
  }

  @override
  String toString() => 'Vec2($x, $y)';

  Map<String, double> toJson() => {'x': x, 'y': y};

  factory Vec2.fromJson(Map<String, dynamic> json) {
    return Vec2(json['x'] as double, json['y'] as double);
  }
}
