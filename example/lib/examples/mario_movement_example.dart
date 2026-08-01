import 'package:flutter/material.dart' hide Animation;
import 'package:flutter/services.dart';
import 'package:tremble/tremble.dart';
import 'package:tremble_example/tex_enum.dart';

class MarioMovementExample extends ScreenController {
  late final SpriteBatch batch;
  late final Mario mario;

  @override
  Future<void> preload(UpdateCallback progress, VoidCallback done) async {
    batch = await SpriteBatch.fromGdxPacker("assets/sprites.atlas", flippable: true);
    done();
  }

  @override
  void setup(BuildContext context, double width, double height) {
    mario = Mario(batch: batch, x: width * 0.5, y: height * 0.5);
  }

  @override
  void update(double deltaTime) {
    mario.update(deltaTime);
    mario.constraintBottom();
  }

  @override
  void draw(Canvas canvas, Size size) {
    batch.draw(canvas, [mario.anim]);
    canvas.drawLine(const Offset(0, 385), Offset(size.width, 385), Paint()..color = Colors.white);
  }

  @override
  void keyDown(LogicalKeyboardKey key) {
    mario.keys.add(key);
  }

  @override
  void keyUp(LogicalKeyboardKey key) {
    mario.keys.remove(key);
  }

  @override
  void dispose() {
    batch.dispose();
  }
}

//////////// MARIO CLASS
enum MarioState { idle, run, jump }

class Mario {
  final Animation<Tex> anim;

  final Vec2 acc = Vec2(0, 900);
  final Vec2 vel = Vec2.zero();
  final state = StateMachine<MarioState>(MarioState.jump);
  final keys = <LogicalKeyboardKey>{};

  Mario({required SpriteBatch batch, required double x, required double y})
      : anim = Animation<Tex>(
          animations: [
            batch.getAnimation(Tex.marioBigJump, speed: 0),
            batch.getAnimation(Tex.marioBigIdle, speed: 0),
            batch.getAnimation(Tex.marioBigRun, speed: 8),
            batch.getAnimation(Tex.marioBigSlide, speed: 0),
          ],
          position: Vec2(x, y),
          scale: 1.5,
        ) {
    state.register(
      MarioState.idle,
      onEnter: () {
        anim.setAnimation(Tex.marioBigIdle);
        vel.x = 0;
      },
      onUpdate: (deltaTime) {
        if (_checkJump()) return;

        if (keys.contains(LogicalKeyboardKey.arrowRight) ||
            keys.contains(LogicalKeyboardKey.arrowLeft)) {
          state.value = MarioState.run;
        }
      },
    );

    state.register(
      MarioState.run,
      onEnter: () {
        anim.setAnimation(Tex.marioBigRun, fromFrame: 0);
      },
      onUpdate: (deltaTime) {
        if (_checkJump()) return;

        _xMove();

        if (acc.x != 0) {
          if (vel.x != 0 && acc.x.sign != vel.x.sign) {
            anim.setAnimation(Tex.marioBigSlide);
          } else {
            anim.setAnimation(Tex.marioBigRun, fromFrame: 0);
          }

          anim.flip = acc.x < 0;
        } else if (vel.x.abs() < 20) {
          state.value = MarioState.idle;
        }
      },
    );

    state.register(
      MarioState.jump,
      onEnter: () => anim.setAnimation(Tex.marioBigJump),
      onUpdate: (deltaTime) => _xMove(),
    );
  }

  void _xMove() {
    acc.x = 0;
    if (keys.contains(LogicalKeyboardKey.arrowRight)) {
      acc.x += 400;
    }
    if (keys.contains(LogicalKeyboardKey.arrowLeft)) {
      acc.x -= 400;
    }
  }

  bool _checkJump() {
    if (keys.contains(LogicalKeyboardKey.arrowUp)) {
      vel.y = -400;
      state.value = MarioState.jump;
      return true;
    }
    return false;
  }

  void update(double deltaTime) {
    state.update(deltaTime);

    vel.add(acc * deltaTime);
    anim.position.add(vel * deltaTime);

    anim.update(deltaTime);

    acc.x = 0;
    vel.x = MathUtils.damp(vel.x, 0, 2.5, deltaTime);
  }

  void constraintBottom() {
    if (anim.position.y > 360 && vel.y >= 0) {
      anim.position.y = 360;
      vel.y = 0;

      if (state.value == MarioState.jump) {
        if (vel.x.abs() < 20) {
          state.value = MarioState.idle;
        } else {
          state.value = MarioState.run;
        }
      }
    }
  }
}
