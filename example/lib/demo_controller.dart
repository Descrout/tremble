import 'package:flutter/material.dart' hide Animation;
import 'package:flutter/services.dart';
import 'package:tremble/tremble.dart';

class DemoController extends ScreenController {
  double mouseX = 0;
  double mouseY = 0;
  bool mouseDown = false;

  final positions = <Offset>[];

  final keys = <LogicalKeyboardKey>{};

  double shootTimer = 0;

  late final SpriteBatch spriteBatch;
  late final Animation hero;

  @override
  Future<void> preload(progress, done) async {
    spriteBatch =
        await SpriteBatch.fromOldGdxPacker("assets/batches/sprites.atlas", flippable: true);
    progress(1.0);
    done();
  }

  @override
  void setup(BuildContext context, double width, double height) {
    hero = Animation(
      animations: [
        spriteBatch.getAnimation("hero-idle", speed: 10),
        spriteBatch.getAnimation("hero-run", speed: 10),
      ],
      x: width / 2,
      y: height - 26,
    );
  }

  @override
  void update(double deltaTime) {
    // X Velocity
    double vx = 0;

    // Move the hero with keyboard
    if (keys.contains(LogicalKeyboardKey.arrowLeft)) vx -= 140;
    if (keys.contains(LogicalKeyboardKey.arrowRight)) vx += 140;

    // Move the hero with mouse
    final deltaX = hero.x - mouseX;
    if (deltaX.abs() > 16) {
      vx -= 140 * deltaX.sign;
    }

    // Set hero animation based on velocity
    if (vx == 0) {
      hero.setAnimation("hero-idle");
    } else {
      hero.setAnimation("hero-run", fromFrame: 0);
      hero.flip = vx < 0;
      hero.x += vx * deltaTime;
    }

    hero.update(deltaTime);

    // Shooting timer
    if (shootTimer <= 0) {
      if (keys.contains(LogicalKeyboardKey.space) || mouseDown) {
        positions.add(Offset(hero.x, hero.y));
      }
      shootTimer = 10;
    } else {
      shootTimer -= deltaTime * 100;
    }

    // Move the bullets to top and if they are out of screen remove them
    for (int i = positions.length - 1; i >= 0; i--) {
      if (positions[i].dy + 16 < 0) {
        positions.removeAt(i);
        continue;
      }
      positions[i] = Offset(positions[i].dx, positions[i].dy - 1000 * deltaTime);
    }
  }

  @override
  void draw(Canvas canvas, Size size) {
    canvas.drawColor(Colors.black, BlendMode.src);

    final paint = Paint()..color = Colors.yellow;

    canvas.drawCircle(Offset(mouseX, mouseY), 8, paint);

    for (final pos in positions) {
      canvas.drawRect(Rect.fromLTWH(pos.dx - 2, pos.dy - 10, 4, 8), paint);
    }

    spriteBatch.draw(canvas, [hero]);
  }

  @override
  void mouseMove(int pointerID, double mouseX, double mouseY) {
    this.mouseX = mouseX;
    this.mouseY = mouseY;
  }

  @override
  void mousePressed(int pointerID, int button, double mouseX, double mouseY) {
    mouseDown = true;
    this.mouseX = mouseX;
    this.mouseY = mouseY;
  }

  @override
  void mouseReleased(int pointerID) {
    mouseDown = false;
  }

  @override
  void keyDown(LogicalKeyboardKey key) {
    keys.add(key);
  }

  @override
  void keyUp(LogicalKeyboardKey key) {
    keys.remove(key);
  }

  @override
  void dispose() {
    spriteBatch.dispose();
  }
}
