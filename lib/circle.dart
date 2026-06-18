import 'package:tremble/vec2.dart';

class Circle {
  Vec2 position;
  double radius;

  Circle({
    required this.position,
    required this.radius,
  });

  double get radSq => radius * radius;

  double get x => position.x;
  double get y => position.y;

  double get left => position.x - radius;
  double get top => position.y - radius;
  double get right => position.x + radius;
  double get bottom => position.y + radius;

  Circle copyWith({
    Vec2? position,
    double? radius,
  }) {
    return Circle(
      position: position ?? this.position,
      radius: radius ?? this.radius,
    );
  }
}
