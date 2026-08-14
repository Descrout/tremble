import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tremble/tremble.dart';

enum LightState { red, green, yellow }

/// A very simple StateMachine demo: a traffic light.
///
/// Each state registers onEnter / onUpdate / onExit. The light cycles
/// automatically, and you can force transitions with the keyboard.
class StateMachineExample extends ScreenController {
  final fsm = StateMachine<LightState>(LightState.red);
  final log = <String>[];

  double _timer = 0;

  final _infoText = CanvasText(
    text: "",
    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
  );
  final _logText = CanvasText(
    text: "",
    style: const TextStyle(color: Colors.amber, fontSize: 13, height: 1.5),
  );
  final _helpText = CanvasText(text: "");

  @override
  void setup(BuildContext context, double width, double height) {
    // Hooks that fire before / after every state change.
    fsm.onBeforeStateChange = (from, to) => _logLine("before: $from -> $to");
    fsm.onAfterStateChange = (from, to) {
      _logLine("after:  $from -> $to");
      _timer = 0;
    };

    // Red: burns 2 seconds, then turns green.
    fsm.register(
      LightState.red,
      onEnter: () => _logLine("enter  red"),
      onUpdate: (dt) => _advance(dt, 2, LightState.green),
      onExit: () => _logLine("exit   red"),
    );

    // Green: burns 2 seconds, then turns yellow.
    fsm.register(
      LightState.green,
      onEnter: () => _logLine("enter  green"),
      onUpdate: (dt) => _advance(dt, 2, LightState.yellow),
      onExit: () => _logLine("exit   green"),
    );

    // Yellow: burns 1 second, then turns red.
    fsm.register(
      LightState.yellow,
      onEnter: () => _logLine("enter  yellow"),
      onUpdate: (dt) => _advance(dt, 1, LightState.red),
      onExit: () => _logLine("exit   yellow"),
    );

    _logLine("started (state: red)");
    _helpText.text = "SPACE : next light\n"
        "1/2/3 : set red / yellow / green\n"
        "R     : reset to red (no events)";
  }

  void _advance(double dt, double seconds, LightState next) {
    _timer += dt;
    if (_timer >= seconds) {
      _timer = 0;
      fsm.value = next; // triggers exit -> enter
    }
  }

  void _next() {
    _timer = 0;
    switch (fsm.value) {
      case LightState.red:
        fsm.value = LightState.green;
      case LightState.green:
        fsm.value = LightState.yellow;
      case LightState.yellow:
        fsm.value = LightState.red;
      case null:
        break;
    }
  }

  @override
  void update(double deltaTime) {
    fsm.update(deltaTime);

    _infoText.text = "current : ${fsm.value!.name.toUpperCase()}\n"
        "previous: ${fsm.previousState?.name ?? "none"}";
    _logText.text = log.join("\n");
  }

  void _logLine(String msg) {
    if (log.isNotEmpty && log.last == msg) return;
    log.add(msg);
    if (log.length > 6) log.removeAt(0);
  }

  @override
  void draw(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFF0f0f1a), BlendMode.src);

    final lightCenter = Offset(size.width * 0.5 - 220, size.height * 0.5);
    _drawTrafficLight(canvas, lightCenter);

    _infoText.draw(canvas, Vec2(lightCenter.dx + 120, lightCenter.dy - 60));
    _logText.draw(canvas, Vec2(lightCenter.dx + 120, lightCenter.dy));
    _helpText.draw(canvas, Vec2(lightCenter.dx + 120, lightCenter.dy + 120));
  }

  void _drawTrafficLight(Canvas canvas, Offset center) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 150, height: 310),
        const Radius.circular(28),
      ),
      Paint()..color = const Color(0xFF1e1e33),
    );

    _drawLamp(canvas, center + const Offset(0, -92), LightState.red);
    _drawLamp(canvas, center + const Offset(0, 0), LightState.yellow);
    _drawLamp(canvas, center + const Offset(0, 92), LightState.green);
  }

  void _drawLamp(Canvas canvas, Offset center, LightState light) {
    final on = fsm.value == light;
    final color = switch (light) {
      LightState.red => Colors.red,
      LightState.green => Colors.green,
      LightState.yellow => Colors.yellow,
    };
    const radius = 44.0;

    canvas.drawCircle(center, radius, Paint()..color = on ? color : const Color(0xFF12121e));

    if (on) {
      canvas.drawCircle(
        center,
        radius + 9,
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      );
    } else {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.grey[800]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  @override
  void keyDown(LogicalKeyboardKey key) {
    switch (key) {
      case LogicalKeyboardKey.space:
        _next();
      case LogicalKeyboardKey.digit1:
        fsm.value = LightState.red;
      case LogicalKeyboardKey.digit2:
        fsm.value = LightState.yellow;
      case LogicalKeyboardKey.digit3:
        fsm.value = LightState.green;
      case LogicalKeyboardKey.keyR:
        _timer = 0;
        fsm.reset(LightState.red); // jumps without firing events
        _logLine("reset -> red");
      default:
        break;
    }
  }

  @override
  void dispose() {}
}
