import 'dart:math';

class Vector2 {
  double x;
  double y;

  // Constructors
  Vector2(this.x, this.y);

  Vector2.zero()
      : x = 0,
        y = 0;

  Vector2.one()
      : x = 1,
        y = 1;

  Vector2.fromAngle(double angle, [double magnitude = 1.0])
      : x = magnitude * cos(angle),
        y = magnitude * sin(angle);

  Vector2.copy(Vector2 other)
      : x = other.x,
        y = other.y;

  // Properties
  double get magnitude => sqrt(x * x + y * y);

  double get magnitudeSquared => x * x + y * y;

  double get angle => atan2(y, x);

  bool get isZero => x == 0 && y == 0;

  // Instance methods
  Vector2 normalized() {
    final mag = magnitude;
    if (mag == 0) return Vector2.zero();
    return Vector2(x / mag, y / mag);
  }

  void normalize() {
    final mag = magnitude;
    if (mag != 0) {
      x /= mag;
      y /= mag;
    }
  }

  Vector2 clamped(double maxLength) {
    final mag = magnitude;
    if (mag > maxLength) {
      final scale = maxLength / mag;
      return Vector2(x * scale, y * scale);
    }
    return Vector2.copy(this);
  }

  void clamp(double maxLength) {
    final mag = magnitude;
    if (mag > maxLength) {
      final scale = maxLength / mag;
      x *= scale;
      y *= scale;
    }
  }

  double distanceTo(Vector2 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }

  double distanceSquaredTo(Vector2 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return dx * dx + dy * dy;
  }

  double dot(Vector2 other) => x * other.x + y * other.y;

  double cross(Vector2 other) => x * other.y - y * other.x;

  Vector2 rotated(double angle) {
    final ccos = cos(angle);
    final ssin = sin(angle);
    return Vector2(
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

  Vector2 lerp(Vector2 other, double t) {
    return Vector2(
      x + (other.x - x) * t,
      y + (other.y - y) * t,
    );
  }

  Vector2 reflected(Vector2 normal) {
    final d = 2 * dot(normal);
    return Vector2(x - d * normal.x, y - d * normal.y);
  }

  void reflect(Vector2 normal) {
    final d = 2 * dot(normal);
    x -= d * normal.x;
    y -= d * normal.y;
  }

  // Operator overloading
  Vector2 operator +(Object other) {
    if (other is Vector2) {
      return Vector2(x + other.x, y + other.y);
    } else if (other is num) {
      return Vector2(x + other, y + other);
    }
    throw ArgumentError('Invalid operand type for +');
  }

  Vector2 operator -(Object other) {
    if (other is Vector2) {
      return Vector2(x - other.x, y - other.y);
    } else if (other is num) {
      return Vector2(x - other, y - other);
    }
    throw ArgumentError('Invalid operand type for -');
  }

  Vector2 operator *(Object other) {
    if (other is Vector2) {
      return Vector2(x * other.x, y * other.y);
    } else if (other is num) {
      return Vector2(x * other, y * other);
    }
    throw ArgumentError('Invalid operand type for *');
  }

  Vector2 operator /(Object other) {
    if (other is Vector2) {
      return Vector2(x / other.x, y / other.y);
    } else if (other is num) {
      return Vector2(x / other, y / other);
    }
    throw ArgumentError('Invalid operand type for /');
  }

  Vector2 operator -() => Vector2(-x, -y);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vector2 && x == other.x && y == other.y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  // Static methods
  static Vector2 add(Vector2 a, Vector2 b) {
    return Vector2(a.x + b.x, a.y + b.y);
  }

  static Vector2 subtract(Vector2 a, Vector2 b) {
    return Vector2(a.x - b.x, a.y - b.y);
  }

  static Vector2 multiply(Vector2 a, Vector2 b) {
    return Vector2(a.x * b.x, a.y * b.y);
  }

  static Vector2 divide(Vector2 a, Vector2 b) {
    return Vector2(a.x / b.x, a.y / b.y);
  }

  static Vector2 scale(Vector2 v, double scalar) {
    return Vector2(v.x * scalar, v.y * scalar);
  }

  static double dotBetween(Vector2 a, Vector2 b) {
    return a.x * b.x + a.y * b.y;
  }

  static double crossBetween(Vector2 a, Vector2 b) {
    return a.x * b.y - a.y * b.x;
  }

  static double distance(Vector2 a, Vector2 b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
  }

  static double distanceSquared(Vector2 a, Vector2 b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return dx * dx + dy * dy;
  }

  static Vector2 lerpBetween(Vector2 a, Vector2 b, double t) {
    return Vector2(
      a.x + (b.x - a.x) * t,
      a.y + (b.y - a.y) * t,
    );
  }

  static Vector2 min(Vector2 a, Vector2 b) {
    return Vector2(
      a.x < b.x ? a.x : b.x,
      a.y < b.y ? a.y : b.y,
    );
  }

  static Vector2 max(Vector2 a, Vector2 b) {
    return Vector2(
      a.x > b.x ? a.x : b.x,
      a.y > b.y ? a.y : b.y,
    );
  }

  static Vector2 clampMagnitude(Vector2 v, double maxLength) {
    final mag = v.magnitude;
    if (mag > maxLength) {
      final scale = maxLength / mag;
      return Vector2(v.x * scale, v.y * scale);
    }
    return Vector2.copy(v);
  }

  static double angleBetween(Vector2 a, Vector2 b) {
    final dotProduct = dotBetween(a, b);
    final magnitudes = a.magnitude * b.magnitude;
    if (magnitudes == 0) return 0;
    return acos((dotProduct / magnitudes).clamp(-1.0, 1.0));
  }

  static Vector2 reflectBetween(Vector2 direction, Vector2 normal) {
    final d = 2 * dotBetween(direction, normal);
    return Vector2(
      direction.x - d * normal.x,
      direction.y - d * normal.y,
    );
  }

  // Utility
  Vector2 clone() => Vector2(x, y);

  void set(double newX, double newY) {
    x = newX;
    y = newY;
  }

  void setFrom(Vector2 other) {
    x = other.x;
    y = other.y;
  }

  @override
  String toString() => 'Vector2($x, $y)';

  Map<String, double> toJson() => {'x': x, 'y': y};

  factory Vector2.fromJson(Map<String, dynamic> json) {
    return Vector2(json['x'] as double, json['y'] as double);
  }
}
