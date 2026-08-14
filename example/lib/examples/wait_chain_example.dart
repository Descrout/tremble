import 'package:flutter/material.dart' hide Animation;
import 'package:flutter/services.dart';
import 'package:tremble/tremble.dart';
import 'package:tremble_example/tex_enum.dart';

/// A cinematic cutscene driven entirely by a [WaitChainBuilder].
///
/// Every step shows the WaitChain API call behind it - run(), waitAndDo(),
/// wait(), waitUntil() - while the [Camera] zooms and pans, and Mario runs and
/// jumps through a small Mushroom Kingdom level built with Grid + TileMap.
class WaitChainExample extends ScreenController {
  static const double groundTop = 384;
  static const double castleX = 820;
  static const int tileGround = 0;
  static const int tileBrick = 1;
  static const int tileCoin = 2;

  late SpriteBatch batch;
  late final TileMap tileMap;
  late CineMario mario;
  final wait = WaitEvents();
  late final Camera camera;

  final grid = Grid.filled(cellSize: 24, width: 36, height: 19, value: -1);
  final decor = <Sprite>[];

  String _caption = "";
  bool _endShow = false;
  double _endAlpha = 0;

  final _captionText = CanvasText(
    text: "",
    style: const TextStyle(
      color: Colors.white,
      fontSize: 17,
      fontWeight: FontWeight.w700,
    ),
    origin: const Offset(0.5, 0),
  );
  final _helpText = CanvasText(
    text: "SPACE - replay cutscene",
    style: const TextStyle(color: Colors.white70, fontSize: 12),
  );
  final _endText = CanvasText(
    text: "THE END",
    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900),
    origin: const Offset(0.5, 0.5),
  );

  @override
  Future<void> preload(UpdateCallback progress, VoidCallback done) async {
    batch = await SpriteBatch.fromGdxPacker("assets/sprites.atlas", flippable: true);
    done();
  }

  @override
  void setup(BuildContext context, double width, double height) {
    camera = Camera(viewportWidth: width, viewportHeight: height);

    tileMap = TileMap(
      tileAreas: [
        batch.getTexture(Tex.groundBlock).rect,
        batch.getTexture(Tex.brick).rect,
        batch.getTexture(Tex.coin).rect,
      ],
      image: batch.image,
      tileScale: 1.5,
    );
    TileMap.paint.color = Colors.white;

    // Ground rows.
    for (int x = 0; x < grid.width; x++) {
      grid.setTile2d(tileGround, x: x, y: 16);
      grid.setTile2d(tileGround, x: x, y: 17);
      grid.setTile2d(tileGround, x: x, y: 18);
    }

    // A brick row with coins on top.
    for (int c = 10; c <= 14; c++) {
      grid.setTile2d(tileBrick, x: c, y: 12);
      grid.setTile2d(tileCoin, x: c, y: 11);
    }

    // Decorative sprites.
    _add(Tex.hill2, 190, groundTop - 12);
    _add(Tex.bush2, 420, groundTop - 16);
    _add(Tex.bush1, 620, groundTop - 16);
    _add(Tex.castle, castleX, groundTop - 40);

    mario = CineMario(batch: batch, x: 150, y: groundTop - 24);
    _playCinematic();
  }

  void _add(Tex t, double x, double y) {
    decor.add(Sprite(texture: batch.getTexture(t), position: Vec2(x, y)));
  }

  void _playCinematic() {
    _endShow = false;
    _endAlpha = 0;

    wait
        .chain()
        // 1. run() - snap the camera to the start.
        .run(() {
          _caption = "run() - snap camera";
          camera.reset();
          camera.y = 0;
          mario.idle();
          mario.anim.position.set(150, groundTop - 24);
        })

        // 2. waitAndDo() - smoothly zoom in on Mario.
        .waitAndDo(1.0, (dt, remaining) {
          _caption = "waitAndDo(1) - smooth zoom in";
          final t = 1.0 - remaining / 1.0;
          camera.zoom = MathUtils.lerp(1.0, 1.6, Parametrics.smoothStep3(t));
          camera.centerX = mario.anim.position.x;
        })

        // 3. waitAndDo() - Mario runs right while the camera follows.
        .waitAndDo(2.8, (dt, remaining) {
          _caption = "waitAndDo(2.8) - Mario runs, camera follows";
          mario.run();
          mario.anim.position.x += 95 * dt;
          camera.centerX = MathUtils.damp(camera.centerX, mario.anim.position.x, 3.0, dt);
        })

        // 4. run() - stop and swap animation back to idle.
        .run(() {
          _caption = "run() - Mario stops";
          mario.idle();
        })

        // 5. wait() - hold for a beat.
        .wait(0.7)

        // 6. waitAndDo() - Mario does a little jump (parabolic arc).
        .waitAndDo(1.2, (dt, remaining) {
          _caption = "waitAndDo(1.2) - jump arc";
          final t = 1.0 - remaining / 1.2;
          mario.jump();
          mario.anim.position.y = groundTop - 24 - Parametrics.arch2(t) * 110;
        })

        // 7. waitAndDo() - zoom back out and pan toward the castle.
        .waitAndDo(2.2, (dt, remaining) {
          _caption = "waitAndDo(2.2) - zoom out, pan to castle";
          final t = 1.0 - remaining / 2.2;
          mario.run();
          mario.anim.position.x += 120 * dt;
          camera.zoom = MathUtils.lerp(1.6, 0.8, Parametrics.smoothStep3(t));
          camera.centerX = MathUtils.lerp(camera.centerX, 640, 2.5 * dt);
        })

        // 8. waitUntil() - keep running until Mario reaches the castle.
        .waitUntil((dt) {
          _caption = "waitUntil - run until castle";
          mario.run();
          mario.anim.position.x += 140 * dt;
          return mario.anim.position.x < castleX - 20;
        })

        // 9. run() - the end.
        .run(() {
          _caption = "run() - the end";
          mario.idle();
          _endShow = true;
        })

        // 10. wait() - hold the finale, then loop automatically.
        .wait(1.6)
        .run(() {
          _caption = "";
          _playCinematic();
        })
        .build();
  }

  @override
  void update(double deltaTime) {
    wait.update(deltaTime);
    mario.update(deltaTime);
    if (_endShow) _endAlpha = (_endAlpha + deltaTime * 1.5).clamp(0.0, 1.0);
  }

  @override
  void draw(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFF5c94fc), BlendMode.src); // sky

    camera.start(canvas);
    tileMap.drawGrid(
      canvas,
      grid,
      cullArea: camera.aabb,
    );
    batch.draw(canvas, decor);
    batch.draw(canvas, [mario.anim]);

    camera.stop(canvas);

    _drawCaption(canvas, size);

    _helpText.draw(canvas, Vec2(size.width - 230, size.height - 40));

    if (_endAlpha > 0) {
      _endText.style = TextStyle(
        color: Colors.white.withValues(alpha: _endAlpha),
        fontSize: 40,
        fontWeight: FontWeight.w900,
      );
      _endText.draw(canvas, Vec2(size.width * 0.5, size.height * 0.42));
    }
  }

  void _drawCaption(Canvas canvas, Size size) {
    if (_caption.isEmpty) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(size.width * 0.5 - 220, 12, size.width * 0.5 + 220, 40),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xAA101020),
    );
    _captionText.text = _caption;
    _captionText.draw(canvas, Vec2(size.width * 0.5, 16));
  }

  @override
  void keyDown(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.space) {
      wait.clear();
      _playCinematic();
    }
  }

  @override
  void dispose() {
    batch.dispose();
  }
}

/////// Cinematic Mario
class CineMario {
  final Animation<Tex> anim;

  CineMario({required SpriteBatch batch, required double x, required double y})
      : anim = Animation<Tex>(
          animations: [
            batch.getAnimation(Tex.marioBigIdle, speed: 0),
            batch.getAnimation(Tex.marioBigRun, speed: 8),
            batch.getAnimation(Tex.marioBigJump, speed: 0),
          ],
          position: Vec2(x, y),
          scale: 1.5,
        );

  void idle() => anim.setAnimation(Tex.marioBigIdle);
  void run() => anim.setAnimation(Tex.marioBigRun, fromFrame: 0);

  void jump() => anim.setAnimation(Tex.marioBigJump);

  void update(double deltaTime) => anim.update(deltaTime);
}
