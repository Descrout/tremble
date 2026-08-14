import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tremble/tremble.dart';

/// A very simple Signal demo.
///
/// Click or press SPACE to dispatch a signal. The receiver boxes on the left
/// flash whenever they get it. Listener 2 auto-removes itself after 3 signals.
class SignalsExample extends ScreenController {
  final signal = Signal<String>();

  int listener1Count = 0;
  double listener1Glow = 0;

  int listener2Count = 0;
  double listener2Glow = 0;
  bool listener2On = true;

  double emitterGlow = 0;
  double valueGlow = 0;

  final _titleText = CanvasText(
    text: "Signals \u2014 click or press SPACE to dispatch",
    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
  );
  final _footText = CanvasText(text: "");

  @override
  void setup(BuildContext context, double width, double height) {
    // Listener 1: always listening, counts every signal.
    signal.listen((msg) {
      listener1Count++;
      listener1Glow = 1;
      return true; // keep listening
    });

    // Listener 2: removes itself (returns false) after 3 signals.
    signal.listen(_listener2);
  }

  bool _listener2(String msg) {
    listener2Count++;
    listener2Glow = 1;
    if (listener2Count >= 3) {
      listener2On = false;
      return false; // unsubscribe
    }
    return true;
  }

  void _send() {
    emitterGlow = 1;
    signal.dispatch("ping");
  }

  void _toggleListener2() {
    if (listener2On) {
      signal.unlisten(_listener2);
      listener2On = false;
      listener2Glow = 0;
    } else {
      listener2Count = 0;
      signal.listen(_listener2);
      listener2On = true;
    }
  }

  @override
  void update(double deltaTime) {
    listener1Glow = (listener1Glow - deltaTime * 3).clamp(0.0, 1.0);
    listener2Glow = (listener2Glow - deltaTime * 3).clamp(0.0, 1.0);
    emitterGlow = (emitterGlow - deltaTime * 3).clamp(0.0, 1.0);
    valueGlow = (valueGlow - deltaTime * 3).clamp(0.0, 1.0);

    _footText.text = "Listener 2 auto-removes after 3 signals. Press U to re-add / remove it.\n"
        "Current subscribers: ${signal.length}";
  }

  @override
  void draw(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFF0f0f1a), BlendMode.src);

    _drawEmitter(canvas);
    _drawBox(canvas, "Listener 1", "always listening", listener1Count, listener1Glow, Colors.cyan,
        const Rect.fromLTWH(40, 200, 360, 68));
    _drawBox(canvas, "Listener 2", listener2On ? "removes itself after 3" : "removed (press U)",
        listener2Count, listener2Glow, Colors.green, const Rect.fromLTWH(40, 290, 360, 68));

    _titleText.draw(canvas, Vec2(40, 110));
    _footText.draw(canvas, Vec2(40, 480));
  }

  void _drawEmitter(Canvas canvas) {
    const center = Offset(600, 175);
    canvas.drawCircle(
      center,
      64,
      Paint()
        ..color =
            Color.lerp(const Color(0xFF1a1a2e), Colors.cyan.withValues(alpha: 0.5), emitterGlow)!
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      64,
      Paint()
        ..color = Colors.cyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    CanvasText(
      text: "SIGNAL",
      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
    ).draw(canvas, Vec2(600, 175));
  }

  void _drawBox(
      Canvas canvas, String label, String status, int count, double glow, Color color, Rect rect) {
    final active = glow > 0;
    final boxColor = active
        ? Color.lerp(const Color(0xFF1a1a2e), color.withValues(alpha: 0.45), glow)!
        : const Color(0xFF1a1a2e);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()..color = boxColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()
        ..color = color.withValues(alpha: active ? 0.9 : 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    CanvasText(
      text: label,
      style: TextStyle(
        color: color,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    ).draw(canvas, Vec2(rect.left + 16, rect.top + 12));

    CanvasText(
      text: status,
      style: TextStyle(
        color: Colors.grey[400],
        fontSize: 12,
      ),
    ).draw(canvas, Vec2(rect.left + 16, rect.top + 34));

    CanvasText(
      text: "$count",
      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
      origin: const Offset(1, 0),
    ).draw(canvas, Vec2(rect.right - 16, rect.top + 10));
  }

  @override
  void mousePressed(int pointerID, int button, double mouseX, double mouseY) {
    _send();
  }

  @override
  void keyDown(LogicalKeyboardKey key) {
    switch (key) {
      case LogicalKeyboardKey.space:
        _send();
      case LogicalKeyboardKey.keyU:
        _toggleListener2();
      default:
        break;
    }
  }

  @override
  void dispose() {}
}
