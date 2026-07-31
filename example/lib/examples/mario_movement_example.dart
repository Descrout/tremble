import 'package:flutter/material.dart' hide Animation;
import 'package:flutter/services.dart';
import 'package:tremble/tremble.dart';
import 'package:tremble_example/tex_enum.dart';

enum MarioState { idle, run, jump }

class MarioMovementExample extends ScreenController {
  late final SpriteBatch batch;
  late final Animation<Tex> mario;

  final Vec2 acc = Vec2(0, 900);
  final Vec2 vel = Vec2.zero();
  final state = StateMachine<MarioState>(MarioState.jump);
  final keys = <LogicalKeyboardKey>{};

  @override
  Future<void> preload(UpdateCallback progress, VoidCallback done) async {
    batch = await SpriteBatch.fromGdxPacker("assets/sprites.atlas", flippable: true);
    done();
  }

  @override
  void setup(BuildContext context, double width, double height) {
    mario = Animation<Tex>(
      animations: [
        batch.getAnimation(Tex.marioBigJump, speed: 0),
        batch.getAnimation(Tex.marioBigIdle, speed: 0),
        batch.getAnimation(Tex.marioBigRun, speed: 8),
        batch.getAnimation(Tex.marioBigSlide, speed: 0),
      ],
      position: Vec2(width * 0.5, height * 0.5),
      scale: 1.5,
    );

    state.register(
      MarioState.idle,
      onEnter: () {
        mario.setAnimation(Tex.marioBigIdle);
        vel.x = 0;
      },
      onUpdate: (deltaTime) {
        if (checkJump()) return;

        if (keys.contains(LogicalKeyboardKey.arrowRight) ||
            keys.contains(LogicalKeyboardKey.arrowLeft)) {
          state.value = MarioState.run;
        }
      },
    );

    state.register(
      MarioState.run,
      onEnter: () {
        mario.setAnimation(Tex.marioBigRun, fromFrame: 0);
      },
      onUpdate: (deltaTime) {
        if (checkJump()) return;

        xMove();

        if (acc.x != 0) {
          if (vel.x != 0 && acc.x.sign != vel.x.sign) {
            mario.setAnimation(Tex.marioBigSlide);
          } else {
            mario.setAnimation(Tex.marioBigRun, fromFrame: 0);
          }

          mario.flip = acc.x < 0;
        } else if (vel.x.abs() < 9) {
          state.value = MarioState.idle;
        }
      },
    );
    state.register(
      MarioState.jump,
      onEnter: () => mario.setAnimation(Tex.marioBigJump),
      onUpdate: (deltaTime) => xMove(),
    );
  }

  void xMove() {
    acc.x = 0;
    if (keys.contains(LogicalKeyboardKey.arrowRight)) {
      acc.x += 400;
    }
    if (keys.contains(LogicalKeyboardKey.arrowLeft)) {
      acc.x -= 400;
    }
  }

  bool checkJump() {
    if (keys.contains(LogicalKeyboardKey.arrowUp)) {
      vel.y = -400;
      state.value = MarioState.jump;
      return true;
    }
    return false;
  }

  @override
  void update(double deltaTime) {
    state.update(deltaTime);

    vel.add(acc * deltaTime);
    mario.position.add(vel * deltaTime);

    mario.update(deltaTime);

    acc.x = 0;
    vel.x = MathUtils.damp(vel.x, 0, 2.5, deltaTime);

    // Collide bottom
    if (mario.position.y > 360 && vel.y >= 0) {
      mario.position.y = 360;
      vel.y = 0;

      if (state.value == MarioState.jump) {
        if (vel.x.abs() < 9) {
          state.value = MarioState.idle;
        } else {
          state.value = MarioState.run;
        }
      }
    }
  }

  @override
  void draw(Canvas canvas, Size size) {
    batch.draw(canvas, [mario]);
    canvas.drawLine(const Offset(0, 385), Offset(size.width, 385), Paint()..color = Colors.white);
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
    batch.dispose();
  }
}
