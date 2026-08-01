import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tremble/tremble.dart';

class ShapeRaycasterExample extends ScreenController {
  static const _bg = Color(0xFF0B0F19);
  static const _lightColor = Color(0xFFFFE9A8);
  static const _hitColor = Color(0xFFFF5D5D);
  static const _normalColor = Color(0xFF5DFFA0);

  static const _maxRange = 900.0;
  static const _rayCount = 130;

  final Vec2 _light = Vec2.zero();
  final Vec2 _target = Vec2.zero();

  final List<Shape> _shapes = [];
  final List<Color> _shapeColors = [];

  final CanvasText _infoText = CanvasText();
  final CanvasText _hintText = CanvasText();

  final List<({Ray ray, RaycastHit<Shape>? hit})> _rays = [];

  int _nearestIndex = -1;
  double _time = 0;

  double _screenW = 800;
  double _screenH = 600;

  @override
  void setup(BuildContext context, double width, double height) {
    _screenW = width;
    _screenH = height;
    _light.set(width * 0.5, height * 0.5);
    _target.setFrom(_light);

    _shapes.add(Circle(Vec2(170, 140), radius: 58));
    _shapes.add(Circle(Vec2(640, 130), radius: 42));
    _shapes.add(Circle(Vec2(620, 500), radius: 64));
    _shapes.add(Circle(Vec2(400, 96), radius: 30));
    _shapes.add(AABB(Vec2(280, 300), width: 110, height: 70));
    _shapes.add(AABB(Vec2(480, 330), width: 70, height: 120));
    _shapes.add(AABB(Vec2(120, 430), width: 90, height: 90));
    _shapes.add(Line(Vec2(330, 70), Vec2(210, 260)));
    _shapes.add(Line(Vec2(460, 480), Vec2(760, 420)));
    _shapes.add(Line(Vec2(30, 540), Vec2(250, 520)));

    _shapeColors.addAll([
      const Color(0xFFFFD54F),
      const Color(0xFF4FC3F7),
      const Color(0xFF81C784),
      const Color(0xFFFF8A65),
      const Color(0xFFBA68C8),
      const Color(0xFFE57373),
      const Color(0xFF4DD0E1),
      const Color(0xFF90CAF9),
      const Color(0xFFF48FB1),
      const Color(0xFFFFD54F),
    ]);

    _infoText.style = const TextStyle(
      color: Color(0xFF9BB0CC),
      fontSize: 13,
      height: 1.6,
      fontFamily: 'monospace',
    );
    _hintText.style = const TextStyle(
      color: Color(0x99AFC0D9),
      fontSize: 12,
      height: 1.4,
      fontFamily: 'monospace',
    );
  }

  @override
  void update(double deltaTime) {
    _time += deltaTime;
    _light.damp(_target, 8, deltaTime);

    _rays.clear();
    _nearestIndex = -1;

    for (int i = 0; i < _rayCount; i++) {
      final angle = 2 * math.pi * i / _rayCount;
      final ray = Ray(origin: _light.clone(), direction: Vec2.fromAngle(angle));

      RaycastHit<Shape>? closest;
      for (final shape in _shapes) {
        final hit = Raycaster.raycastShape(ray, shape);
        if (hit == null) continue;
        if (closest == null || hit.distance < closest.distance) closest = hit;
      }

      if (closest != null &&
          (_nearestIndex < 0 || closest.distance < _rays[_nearestIndex].hit!.distance)) {
        _nearestIndex = _rays.length;
      }

      _rays.add((ray: ray, hit: closest));
    }

    _updateText();
  }

  @override
  void draw(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);

    _drawGlow(canvas);

    for (int i = 0; i < _shapes.length; i++) {
      _drawShape(canvas, _shapes[i], _shapeColors[i]);
    }

    for (final r in _rays) {
      final d = r.hit?.distance ?? _maxRange;
      final end = r.hit?.point ?? r.ray.pointAt(_maxRange);
      _drawRay(canvas, r.ray.origin, end, d);

      if (r.hit != null) _drawHit(canvas, r.hit!.point);
    }

    for (final r in _rays) {
      if (r.hit == null) continue;
      _drawNormal(canvas, r.hit!.point, r.hit!.normal, scale: 18);
    }

    if (_nearestIndex >= 0) {
      final hit = _rays[_nearestIndex].hit!;
      _drawClosestMarker(canvas, hit.point, hit.normal);
    }

    _drawLight(canvas);
    _infoText.draw(canvas, Vec2(14, 12));
    _hintText.draw(canvas, Vec2(14, size.height - 30));
  }

  ////// Shape drawing

  void _drawShape(Canvas canvas, Shape shape, Color color) {
    shape.draw(canvas, color.withValues(alpha: 0.22), false);

    Shape.paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = color;

    if (shape is Circle) {
      canvas.drawCircle(shape.position.offset(), shape.radius, Shape.paint);
      _drawSmallDot(canvas, shape.position, color.withValues(alpha: 0.9));
    } else if (shape is AABB) {
      canvas.drawRect(shape.rect, Shape.paint);
      _drawSmallDot(canvas, shape.position, color.withValues(alpha: 0.9));
    } else if (shape is Line) {
      canvas.drawLine(shape.p1.offset(), shape.p2.offset(), Shape.paint);
      _drawSmallDot(canvas, shape.p1, color.withValues(alpha: 0.9));
      _drawSmallDot(canvas, shape.p2, color.withValues(alpha: 0.9));
    }
  }

  ////// Debug primitives

  void _drawGlow(Canvas canvas) {
    final glow = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0x38FFC857),
          Color(0x14FFC857),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: _light.offset(), radius: _maxRange),
      );
    canvas.drawRect(Offset.zero & Size(_screenW, _screenH), glow);
  }

  Color _rayColor(double distance) {
    final t = (distance / _maxRange).clamp(0.0, 1.0);
    final base = Color.lerp(const Color(0xFFFFD54F), const Color(0xFFFF5252), t)!;
    return base.withValues(alpha: 0.15 + 0.65 * (1 - t));
  }

  void _drawRay(Canvas canvas, Vec2 from, Vec2 end, double distance) {
    final color = _rayColor(distance);
    final a = from.offset();
    final b = end.offset();

    Shape.paint
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: color.a * 0.25)
      ..strokeWidth = 6;
    canvas.drawLine(a, b, Shape.paint);

    Shape.paint
      ..color = color
      ..strokeWidth = 1.6;
    canvas.drawLine(a, b, Shape.paint);
  }

  void _drawHit(Canvas canvas, Vec2 point) {
    Shape.paint
      ..style = PaintingStyle.fill
      ..color = _hitColor.withValues(alpha: 0.22);
    canvas.drawCircle(point.offset(), 7, Shape.paint);

    Shape.paint.color = _hitColor;
    canvas.drawCircle(point.offset(), 3, Shape.paint);
  }

  void _drawNormal(Canvas canvas, Vec2 point, Vec2 normal, {double scale = 18}) {
    Shape.paint.strokeWidth = 2;
    normal.draw(canvas, _normalColor, origin: point.offset(), scale: scale, drawArrowHead: false);
  }

  void _drawClosestMarker(Canvas canvas, Vec2 point, Vec2 normal) {
    final pulse = 8 + 3 * math.sin(_time * 5);

    Shape.paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = _lightColor;
    canvas.drawCircle(point.offset(), pulse, Shape.paint);

    Shape.paint.strokeWidth = 3;
    normal.draw(canvas, _normalColor, origin: point.offset(), scale: 34, drawArrowHead: false);
  }

  void _drawLight(Canvas canvas) {
    final p = _light.offset();

    Shape.paint
      ..style = PaintingStyle.fill
      ..color = _lightColor.withValues(alpha: 0.16);
    canvas.drawCircle(p, 28, Shape.paint);

    Shape.paint.color = _lightColor;
    canvas.drawCircle(p, 5, Shape.paint);

    Shape.paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = _lightColor.withValues(alpha: 0.6);
    canvas.drawLine(p + const Offset(-13, 0), p + const Offset(13, 0), Shape.paint);
    canvas.drawLine(p + const Offset(0, -13), p + const Offset(0, 13), Shape.paint);
  }

  void _drawSmallDot(Canvas canvas, Vec2 position, Color color) {
    Shape.paint
      ..style = PaintingStyle.fill
      ..color = color;
    canvas.drawCircle(position.offset(), 3, Shape.paint);
  }

  ////// Text

  void _updateText() {
    final sb = StringBuffer();
    sb.writeln("RAYCASTER DEBUG VIEW");
    sb.writeln("rays: $_rayCount");

    if (_nearestIndex >= 0) {
      final hit = _rays[_nearestIndex].hit!;
      sb.writeln("dist   : ${hit.distance.toStringAsFixed(1)}px");
      sb.writeln(
          "normal : (${hit.normal.x.toStringAsFixed(2)}, ${hit.normal.y.toStringAsFixed(2)})");
    } else {
      sb.writeln("nearest: none");
    }

    _infoText.text = sb.toString();
    _hintText.text = "move: light source  •  space: add a shape";
  }

  ////// Input

  @override
  void mouseMove(int pointerID, double mouseX, double mouseY) {
    _target.set(
      mouseX.clamp(6, _screenW - 6),
      mouseY.clamp(6, _screenH - 6),
    );
  }

  @override
  void mousePressed(int pointerID, int button, double mouseX, double mouseY) {
    if (button == 1) {
      _shapes.add(Circle(Vec2(mouseX, mouseY), radius: MathUtils.randDouble(18, 42)));
      _shapeColors.add(ColorUtils.randomColor(ColorMood.bright, opacity: 0.95));
    }
  }

  @override
  void dispose() {
    Shape.paint.strokeWidth = 1;
  }
}
