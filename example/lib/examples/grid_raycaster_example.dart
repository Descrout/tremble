import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tremble/tremble.dart';

class GridRaycasterExample extends ScreenController {
  static const _bg = Color(0xFF0B0F19);
  static const _lightColor = Color(0xFFFFE9A8);
  static const _hitColor = Color(0xFFFF5D5D);
  static const _normalColor = Color(0xFF5DFFA0);

  static const _maxRange = 900.0;
  static const _rayCount = 72;

  final Vec2 _light = Vec2.zero();
  final Vec2 _target = Vec2.zero();

  late Grid<int> _grid;

  final CanvasText _infoText = CanvasText();
  final CanvasText _hintText = CanvasText();

  final List<({Ray ray, RaycastGridHit? hit})> _rays = [];

  RaycastGridHit? _nearest;
  double _time = 0;

  double _screenW = 800;
  double _screenH = 600;

  @override
  void setup(BuildContext context, double width, double height) {
    _screenW = width;
    _screenH = height;
    _light.set(width * 0.5, height * 0.5);
    _target.setFrom(_light);

    _grid = Grid.filled(cellSize: 20, width: 40, height: 30, value: -1);
    for (int x = 0; x < _grid.width; x++) {
      _grid.setTile2d(0, x: x, y: 0);
      _grid.setTile2d(0, x: x, y: _grid.height - 1);
    }
    for (int y = 0; y < _grid.height; y++) {
      _grid.setTile2d(0, x: 0, y: y);
      _grid.setTile2d(0, x: _grid.width - 1, y: y);
    }

    final rnd = math.Random(7);
    for (int y = 2; y < _grid.height - 2; y++) {
      for (int x = 2; x < _grid.width - 2; x++) {
        if (rnd.nextDouble() < 0.13) _grid.setTile2d(1, x: x, y: y);
      }
    }

    _infoText.style = const TextStyle(
      color: Color(0xffffffff),
      fontSize: 13,
      height: 1.6,
      fontFamily: 'monospace',
    );
    _hintText.style = const TextStyle(
      color: Color(0xffffffff),
      fontSize: 12,
      height: 1.4,
      fontFamily: 'monospace',
    );
  }

  @override
  void update(double deltaTime) {
    _time += deltaTime;
    _light.damp(_target, 8, deltaTime);

    bool isSolid(int x, int y) => _grid.inBounds2d(x, y) && _grid.tileAt2d(x, y) >= 0;

    _rays.clear();
    _nearest = null;

    for (int i = 0; i < _rayCount; i++) {
      final angle = 2 * math.pi * i / _rayCount;
      final ray = Ray(origin: _light.clone(), direction: Vec2.fromAngle(angle));

      final hit = Raycaster.raycastGrid(
        ray,
        cellSize: _grid.cellSize,
        maxDistance: _maxRange,
        isSolid: isSolid,
      );

      if (hit != null && (_nearest == null || hit.distance < _nearest!.distance)) {
        _nearest = hit;
      }

      _rays.add((ray: ray, hit: hit));
    }

    _updateText();
  }

  @override
  void draw(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);

    _drawGlow(canvas);

    _grid.debugDraw(canvas);

    for (final r in _rays) {
      final d = r.hit?.distance ?? _maxRange;
      final end = r.hit?.point ?? r.ray.pointAt(_maxRange);
      _drawRay(canvas, r.ray.origin, end, d);
    }

    final cell = _grid.cellSize.toDouble();
    for (final r in _rays) {
      final hit = r.hit;
      if (hit == null) continue;

      Shape.paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _hitColor.withValues(alpha: 0.85);
      canvas.drawRect(
        Rect.fromLTWH(hit.tx * cell, hit.ty * cell, cell, cell),
        Shape.paint,
      );

      _drawNormal(canvas, hit.point, Vec2(hit.normalX.toDouble(), hit.normalY.toDouble()),
          scale: 16);
    }

    if (_nearest != null) {
      _drawClosestMarker(canvas, _nearest!);
    }

    _drawLight(canvas);
    _infoText.draw(canvas, Vec2(24, 16));
    _hintText.draw(canvas, Vec2(24, size.height - 36));
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

  void _drawNormal(Canvas canvas, Vec2 point, Vec2 normal, {double scale = 18}) {
    Shape.paint.strokeWidth = 2;
    normal.draw(canvas, _normalColor, origin: point.offset(), scale: scale, drawArrowHead: false);
  }

  void _drawClosestMarker(Canvas canvas, RaycastGridHit hit) {
    final pulse = 8 + 3 * math.sin(_time * 5);
    final cell = _grid.cellSize.toDouble();
    final center = Vec2((hit.tx + 0.5) * cell, (hit.ty + 0.5) * cell);

    Shape.paint
      ..style = PaintingStyle.fill
      ..color = _hitColor.withValues(alpha: 0.18);
    canvas.drawCircle(center.offset(), cell * 0.55, Shape.paint);

    Shape.paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = _lightColor;
    canvas.drawCircle(center.offset(), pulse, Shape.paint);

    Shape.paint.strokeWidth = 3;
    Vec2(hit.normalX.toDouble(), hit.normalY.toDouble()).draw(canvas, _normalColor,
        origin: center.offset(), scale: cell * 0.45, drawArrowHead: false);
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

  ////// Text

  void _updateText() {
    final sb = StringBuffer();
    sb.writeln("GRID RAYCASTER DEBUG VIEW");
    sb.writeln("rays: $_rayCount");

    if (_nearest != null) {
      sb.writeln("hit : cell(${_nearest!.tx},${_nearest!.ty})");
      sb.writeln("dist: ${_nearest!.distance.toStringAsFixed(1)}px");
      sb.writeln("norm: (${_nearest!.normalX}, ${_nearest!.normalY})");
    } else {
      sb.writeln("hit : none");
    }

    _infoText.text = sb.toString();
    _hintText.text = "move: light source  •  click: toggle wall";
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
    final (gx, gy) = _grid.screenToGrid(mouseX, mouseY);
    if (!_grid.inBounds2d(gx, gy)) return;

    final current = _grid.tileAt2d(gx, gy);
    _grid.setTile2d(current < 0 ? 1 : -1, x: gx, y: gy);
  }

  @override
  void dispose() {
    Shape.paint.strokeWidth = 1;
  }
}
