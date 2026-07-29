import 'package:flutter/material.dart';
import 'package:tremble/physics/vec2.dart';

class CanvasText {
  TextPainter? _painter;

  String _text = '';
  TextStyle _style = const TextStyle();
  TextDirection _direction = TextDirection.ltr;
  TextAlign _align = TextAlign.left;

  bool _dirty = true;

  Offset origin;

  CanvasText({
    String text = '',
    TextStyle style = const TextStyle(color: Colors.white),
    TextDirection direction = TextDirection.ltr,
    TextAlign align = TextAlign.left,
    this.origin = Offset.zero,
  }) {
    _text = text;
    _style = style;
    _direction = direction;
    _align = align;
  }

  String get text => _text;

  set text(String value) {
    if (_text == value) return;
    _text = value;
    _dirty = true;
  }

  TextStyle get style => _style;

  set style(TextStyle value) {
    if (_style == value) return;
    _style = value;
    _dirty = true;
  }

  Size get size {
    _update();
    return Size(_painter!.width, _painter!.height);
  }

  void _update() {
    if (!_dirty) return;

    _painter = TextPainter(
      text: TextSpan(
        text: _text,
        style: _style,
      ),
      textDirection: _direction,
      textAlign: _align,
    )..layout();

    _dirty = false;
  }

  void draw(Canvas canvas, Vec2 position) {
    _update();
    _painter!.paint(
        canvas,
        position.offset(
          dx: -_painter!.width * origin.dx,
          dy: -_painter!.height * origin.dy,
        ));
  }
}
