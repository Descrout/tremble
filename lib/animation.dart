import 'package:tremble/sprite.dart';
import 'package:tremble/tex_area.dart';

enum AnimMode {
  playOnce,
  playOnceReset,
  pingPong,
  loop,
}

int _clampToRange(int value, int min, int max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

class AnimationData<T extends Enum> {
  AnimationData({
    required this.name,
    required this.frames,
    required this.speed,
  })  : assert(frames.isNotEmpty, 'AnimationData "$name" must contain at least 1 frame'),
        assert(speed >= 0, 'speed must be non-negative');

  final T name;
  final List<TexArea> frames;
  final double speed;
}

class Animation<T extends Enum> extends Sprite {
  Animation({
    required List<AnimationData<T>> animations,
    required super.position,
    int index = 0,
    this.mode = AnimMode.loop,
    bool reverse = false,
    super.originX = 0.5,
    super.originY = 0.5,
    super.opacity = 255,
    super.scale = 1.0,
    super.rotation = 0,
  })  : assert(animations.isNotEmpty, "you have to provide atleast 1 AnimationData"),
        _animations = Map.fromEntries(animations.map((e) => MapEntry(e.name, e))),
        _state = animations.first.name,
        _reverse = reverse,
        _direction = reverse ? -1 : 1,
        _index = reverse ? animations.first.frames.length - 1 : index,
        _timer = reverse ? (animations.first.frames.length - 1).toDouble() : index.toDouble(),
        super(
          texture: animations.first.frames[reverse ? animations.first.frames.length - 1 : index],
        ) {
    assert(
      reverse || (index >= 0 && index < animations.first.frames.length),
      "initial index is out of bounds for the first animation",
    );
  }

  final Map<T, AnimationData<T>> _animations;

  bool paused = false;
  AnimMode mode;

  bool _reverse;
  bool get reverse => _reverse;
  set reverse(bool value) {
    _reverse = value;
    _direction = value ? -1 : 1;
  }

  T _state;
  T get currentState => _state;

  double _timer;
  int _direction;

  AnimationData<T> get currentAnimation => _animations[_state]!;

  bool _finished = false;
  bool get finished => _finished;

  int _index;
  int get index => _index;
  set index(int val) {
    final frameCount = currentAnimation.frames.length;
    _index = _clampToRange(val, 0, frameCount - 1);
    _timer = _index.toDouble();
  }

  void update(double deltaTime) {
    if (paused) return;

    _finished = false;

    switch (mode) {
      case AnimMode.playOnce:
        _updatePlayOnce(deltaTime);
        break;
      case AnimMode.playOnceReset:
        _updatePlayOnceReset(deltaTime);
        break;
      case AnimMode.loop:
        _updateLoop(deltaTime);
        break;
      case AnimMode.pingPong:
        _updatePingPong(deltaTime);
        break;
    }
  }

  void _updatePlayOnce(double deltaTime) {
    final anim = currentAnimation;

    final frameCount = anim.frames.length;
    if (frameCount <= 1) {
      _index = 0;
      _finished = true;
      paused = true;
      texture = anim.frames[_index];
      return;
    }

    _timer += _direction * anim.speed * deltaTime;

    if (_direction > 0) {
      if (_timer >= frameCount - 1) {
        _index = frameCount - 1;
        _finished = true;
        paused = true;
      } else {
        _index = _timer.toInt();
      }
    } else {
      if (_timer < 0) {
        _index = 0;
        _finished = true;
        paused = true;
      } else {
        _index = _timer.toInt();
      }
    }

    texture = anim.frames[_index];
  }

  void _updatePlayOnceReset(double deltaTime) {
    final anim = currentAnimation;
    final frameCount = anim.frames.length;
    if (frameCount <= 1) {
      _index = 0;
      _finished = true;
      paused = true;
      texture = anim.frames[_index];
      return;
    }

    _timer += _direction * anim.speed * deltaTime;

    if (_direction > 0) {
      if (_timer >= frameCount) {
        _index = 0;
        _timer = 0;
        _finished = true;
        paused = true;
      } else {
        _index = _timer.toInt();
      }
    } else {
      if (_timer < 0) {
        _index = frameCount - 1;
        _timer = (frameCount - 1).toDouble();
        _finished = true;
        paused = true;
      } else {
        _index = _timer.toInt();
      }
    }

    texture = anim.frames[_index];
  }

  void _updateLoop(double deltaTime) {
    final anim = currentAnimation;

    final frameCount = anim.frames.length;
    if (frameCount <= 1) {
      _index = 0;
      texture = anim.frames[_index];
      return;
    }

    _timer += _direction * anim.speed * deltaTime;
    _timer %= frameCount;

    _index = _clampToRange(_timer.toInt(), 0, frameCount - 1);
    texture = anim.frames[_index];
  }

  void _updatePingPong(double deltaTime) {
    final anim = currentAnimation;

    final frameCount = anim.frames.length;
    if (frameCount <= 1) {
      _index = 0;
      texture = anim.frames[_index];
      return;
    }

    final cycleLength = 2 * (frameCount - 1);
    _timer += _direction * anim.speed * deltaTime;

    _timer %= cycleLength;

    final folded = _timer <= frameCount - 1 ? _timer : cycleLength - _timer;

    _index = _clampToRange(folded.toInt(), 0, frameCount - 1);
    texture = anim.frames[_index];
  }

  void setAnimation(T name, {int? fromFrame}) {
    if (_state == name) return;
    resetAnimation(name, fromFrame: fromFrame);
  }

  void resetAnimation(T name, {int? fromFrame}) {
    assert(_animations.containsKey(name), 'Animation "$name" was not registered');

    paused = false;
    _state = name;
    _direction = reverse ? -1 : 1;

    final frameCount = currentAnimation.frames.length;

    if (fromFrame != null) {
      index = _clampToRange(fromFrame, 0, frameCount - 1);
    } else if (reverse) {
      index = frameCount - 1;
    } else {
      index = 0;
    }
  }
}
