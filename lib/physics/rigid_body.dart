import 'package:tremble/physics/shape.dart';
import 'package:tremble/physics/vec2.dart';

class RigidBody {
  Shape shape;

  Vec2 velocity;
  double mass;
  double elasticity;
  bool isStatic;

  RigidBody({
    required this.shape,
    Vec2? velocity,
    this.mass = 1.0,
    this.elasticity = 0.5,
    this.isStatic = false,
  }) : velocity = velocity ?? Vec2.zero();

  double get invMass => isStatic || mass == 0 ? 0 : 1 / mass;

  void applyImpulse(Vec2 impulse) {
    if (isStatic) return;
    velocity.x += impulse.x * invMass;
    velocity.y += impulse.y * invMass;
  }

  void update(double dt) {
    if (isStatic) return;
    shape.position.x += velocity.x * dt;
    shape.position.y += velocity.y * dt;
  }

  RigidBody copyWith({
    Shape? shape,
    Vec2? velocity,
    double? mass,
    double? elasticity,
    bool? isStatic,
  }) {
    return RigidBody(
      shape: shape ?? this.shape,
      velocity: velocity ?? this.velocity,
      mass: mass ?? this.mass,
      elasticity: elasticity ?? this.elasticity,
      isStatic: isStatic ?? this.isStatic,
    );
  }
}
