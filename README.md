# Tremble

A simple Flutter game engine following the setup/update/draw pattern (p5.js, Processing, Raylib, LÖVE style).

> 📖 **Full documentation**: [tremble-docs.netlify.app](https://tremble-docs.netlify.app/)

## Quick Start

```dart
FittedBox(
  child: SizedBox(
    width: 480,
    height: 640,
    child: GameArea(controller: MyController()),
  ),
)
```

```dart
class MyController extends ScreenController {
  @override
  void setup(BuildContext context, double width, double height) {}

  @override
  void resize(double width, double height) {}

  @override
  void update(double deltaTime) {}

  @override
  void draw(Canvas canvas, Size size) {}

  @override
  void dispose() {}
}
```

## Features

| Area          | Includes |
|---------------|----------|
| **Rendering** | Raw `Canvas` access, `SpriteBatch` (GDX atlases + custom), `Sprite`, `Animation` |
| **Input**     | Keyboard, mouse, resize, scroll |
| **Camera**    | `Camera` with zoom, shake, nesting |
| **Tooling**   | `Signal` / `SignalBuilder`, `WaitEvents` / `WaitChainBuilder`, `StateMachine` |
| **Collision** | `CollisionDetector`, `AABB`, `Circle`, `Line` |
| **Utilities** | `Vec2`, `Tween`, `SecondOrderDynamics`, `ColorUtils`, `MathUtils`, `ImageUtils`, `Extensions`, `Helpers`, `Spring2D` |

## Packages

- [Tremble](https://pub.dev/packages/tremble)
- [TECS](https://pub.dev/packages/tecs) — standalone ECS library
- [Lunapulse](https://descrout.itch.io/lunapulse) — example game built with Tremble + TECS

## License

MIT
