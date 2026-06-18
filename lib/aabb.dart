import 'package:tremble/vec2.dart';

class AABB {
  Vec2 position;
  double width;
  double height;

  AABB({
    required this.position,
    required this.width,
    required this.height,
  });

  double get x => position.x;
  double get y => position.y;

  double get left => position.x;
  double get top => position.y;
  double get right => position.x + width;
  double get bottom => position.y + height;

  AABB copyWith({
    Vec2? position,
    double? width,
    double? height,
  }) {
    return AABB(
      position: position ?? this.position,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
