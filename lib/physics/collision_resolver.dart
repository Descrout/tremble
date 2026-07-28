import 'package:tremble/physics/circle.dart';
import 'package:tremble/physics/line.dart';
import 'package:tremble/physics/rigid_body.dart';
import 'package:tremble/physics/vec2.dart';

abstract final class CollisionResolver {
  static final _temp = Vec2.zero();
  static final _temp2 = Vec2.zero();

  static void _closestPointOnLine(Vec2 point, Line line, Vec2 out) {
    // lineVec = line.p2 - line.p1
    _temp.set(line.p2.x - line.p1.x, line.p2.y - line.p1.y);
    final lineLenSq = _temp.magnitudeSquared;
    if (lineLenSq == 0) {
      out.set(line.p1.x, line.p1.y);
      return;
    }

    // t = dot(point - line.p1, lineVec) / lineLenSq
    final t = ((point.x - line.p1.x) * _temp.x + (point.y - line.p1.y) * _temp.y) / lineLenSq;
    final tc = t.clamp(0.0, 1.0);

    // out = line.p1 + lineVec * tc
    out.set(line.p1.x + _temp.x * tc, line.p1.y + _temp.y * tc);
  }

  static bool circleToCircle(RigidBody aBody, RigidBody bBody) {
    final a = aBody.shape as Circle;
    final b = bBody.shape as Circle;

    // diff = a.position - b.position
    _temp.set(a.position.x - b.position.x, a.position.y - b.position.y);
    final distSq = _temp.magnitudeSquared;
    final rSum = a.radius + b.radius;

    if (distSq >= rSum * rSum) return false;

    final dist = distSq == 0 ? 0.0 : _temp.magnitude;
    if (dist == 0) {
      _temp.set(0, 1);
    } else {
      _temp.scale(1 / dist);
    }

    final penetration = rSum - dist;
    final totalInvMass = aBody.invMass + bBody.invMass;
    if (totalInvMass == 0) return true;

    final correction = penetration / totalInvMass;
    a.position.x += _temp.x * correction * aBody.invMass;
    a.position.y += _temp.y * correction * aBody.invMass;
    b.position.x -= _temp.x * correction * bBody.invMass;
    b.position.y -= _temp.y * correction * bBody.invMass;

    // relVel = aBody.velocity - bBody.velocity
    _temp2.set(aBody.velocity.x - bBody.velocity.x, aBody.velocity.y - bBody.velocity.y);
    final sepVel = _temp2.x * _temp.x + _temp2.y * _temp.y;

    if (sepVel > 0) return true;

    final e = aBody.elasticity < bBody.elasticity ? aBody.elasticity : bBody.elasticity;
    final impulseScalar = -(1 + e) * sepVel / totalInvMass;

    aBody.velocity.x += _temp.x * impulseScalar * aBody.invMass;
    aBody.velocity.y += _temp.y * impulseScalar * aBody.invMass;
    bBody.velocity.x -= _temp.x * impulseScalar * bBody.invMass;
    bBody.velocity.y -= _temp.y * impulseScalar * bBody.invMass;

    return true;
  }

  static bool circleToStaticLine(RigidBody body, Line line) {
    final circle = body.shape as Circle;

    _closestPointOnLine(circle.position, line, _temp2);

    // diff = circle.position - closest
    _temp.set(circle.position.x - _temp2.x, circle.position.y - _temp2.y);
    final distSq = _temp.magnitudeSquared;

    if (distSq >= circle.radius * circle.radius) return false;

    final dist = distSq == 0 ? 0.0 : _temp.magnitude;
    if (dist == 0) {
      _temp.set(0, 1);
    } else {
      _temp.scale(1 / dist);
    }

    final penetration = circle.radius - dist;
    circle.position.x += _temp.x * penetration;
    circle.position.y += _temp.y * penetration;

    final sepVel = body.velocity.x * _temp.x + body.velocity.y * _temp.y;

    if (sepVel > 0) return true;

    final impulse = -sepVel * body.elasticity + sepVel;

    body.velocity.x += _temp.x * impulse;
    body.velocity.y += _temp.y * impulse;

    return true;
  }
}
