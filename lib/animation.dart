import 'package:tremble/sprite.dart';
import 'package:tremble/tex_area.dart';

class AnimationData {
  AnimationData({
    required this.name,
    required this.frames,
    required this.speed,
    required this.loop,
  });

  final String name;
  final List<TexArea> frames;
  final double speed;
  final bool loop;
}

class Animation extends Sprite {
  Animation({
    required List<AnimationData> animations,
    required super.position,
    int index = 0,
    super.originX = 0.5,
    super.originY = 0.5,
    super.opacity = 255,
    super.scale = 1.0,
    super.rotation = 0,
  })  : assert(animations.isNotEmpty, "you have to provide atleast 1 AnimationData"),
        _index = index,
        _timer = index.toDouble(),
        _animations = Map.fromEntries(animations.map((e) => MapEntry(e.name, e))),
        _state = animations.first.name,
        super(texture: animations.first.frames[index]);

  final Map<String, AnimationData> _animations;

  bool paused = false;
  String _state;
  double _timer;

  AnimationData get currentAnimation => _animations[_state]!;

  bool _finished = false;
  bool get finished => _finished;

  int _index;
  int get index => _index;
  set index(int val) {
    _index = val;
    _timer = val.toDouble();
  }

  void update(double deltaTime) {
    if (paused) {
      texture = currentAnimation.frames[_index];
      return;
    }

    _finished = false;

    if (_index < 0) {
      index = 0;
      if (currentAnimation.loop) {
        index = currentAnimation.frames.length - 1;
      } else {
        index = 0;
        _finished = true;
      }
    } else if (_index >= currentAnimation.frames.length) {
      if (currentAnimation.loop) {
        index = 0;
      } else {
        index = currentAnimation.frames.length - 1;
        _finished = true;
      }
    } else {
      _timer += currentAnimation.speed * deltaTime;
    }

    texture = currentAnimation.frames[_index];
    _index = _timer.toInt();
  }

  void setAnimation(String name, {int? fromFrame}) {
    if (_state == name) return;
    resetAnimation(name, fromFrame: fromFrame);
  }

  void resetAnimation(String name, {int? fromFrame}) {
    paused = false;
    _state = name;
    if (fromFrame != null) {
      index = fromFrame;
    }
  }
}
