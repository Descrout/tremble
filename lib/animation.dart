import 'package:tremble/sprite.dart';
import 'package:tremble/tex_area.dart';

enum AnimMode {
  playStop,
  playReset,
  pingPong,
  loop,
}

class AnimationData {
  AnimationData({
    required this.name,
    required this.frames,
    required this.speed,
  });

  final String name;
  final List<TexArea> frames;
  final double speed;
}

class Animation extends Sprite {
  Animation({
    required List<AnimationData> animations,
    required super.position,
    int index = 0,
    this.mode = AnimMode.loop,
    this.reverse = false,
    super.originX = 0.5,
    super.originY = 0.5,
    super.opacity = 255,
    super.scale = 1.0,
    super.rotation = 0,
  })  : assert(animations.isNotEmpty, "you have to provide atleast 1 AnimationData"),
        _animations = Map.fromEntries(animations.map((e) => MapEntry(e.name, e))),
        _state = animations.first.name,
        _direction = reverse ? -1 : 1,
        _index = reverse ? animations.first.frames.length - 1 : index,
        _timer = reverse ? (animations.first.frames.length - 1).toDouble() : index.toDouble(),
        super(
            texture: animations.first.frames[reverse ? animations.first.frames.length - 1 : index]);

  final Map<String, AnimationData> _animations;

  bool paused = false;
  AnimMode mode;
  bool reverse;
  String _state;
  double _timer;
  int _direction;

  AnimationData get currentAnimation => _animations[_state]!;

  bool _finished = false;
  bool get finished => _finished;

  int _index;
  int get index => _index;
  set index(int val) {
    _index = val;
    _timer = val.toDouble();
  }

  int _actualIndex(int frameCount) {
    return reverse ? (frameCount - 1 - _index) : _index;
  }

  void update(double deltaTime) {
    if (paused) {
      if (_index >= 0 && _index < currentAnimation.frames.length) {
        texture = currentAnimation.frames[_actualIndex(currentAnimation.frames.length)];
      }
      return;
    }

    _finished = false;

    if (mode == AnimMode.playStop) {
      _updatePlayStop(deltaTime);
    } else if (mode == AnimMode.playReset) {
      _updatePlayReset(deltaTime);
    } else if (mode == AnimMode.loop) {
      _updateLoop(deltaTime);
    } else if (mode == AnimMode.pingPong) {
      _updatePingPong(deltaTime);
    }
  }

  void _updatePlayStop(double deltaTime) {
    final frameCount = currentAnimation.frames.length;
    _timer += _direction * currentAnimation.speed * deltaTime;

    if (_direction > 0) {
      if (_timer >= frameCount - 1) {
        _index = frameCount - 1;
        _finished = true;
      } else {
        _index = _timer.toInt();
      }
    } else {
      if (_timer < 0) {
        _index = 0;
        _finished = true;
      } else {
        _index = _timer.toInt();
      }
    }

    texture = currentAnimation.frames[_actualIndex(frameCount)];
  }

  void _updatePlayReset(double deltaTime) {
    final frameCount = currentAnimation.frames.length;
    _timer += _direction * currentAnimation.speed * deltaTime;

    if (_direction > 0) {
      if (_timer >= frameCount) {
        _index = 0;
        _timer = 0;
        _finished = true;
      } else {
        _index = _timer.toInt();
      }
    } else {
      if (_timer < 0) {
        _index = frameCount - 1;
        _timer = (frameCount - 1).toDouble();
        _finished = true;
      } else {
        _index = _timer.toInt();
      }
    }

    texture = currentAnimation.frames[_actualIndex(frameCount)];
  }

  void _updateLoop(double deltaTime) {
    final frameCount = currentAnimation.frames.length;
    _timer += _direction * currentAnimation.speed * deltaTime;

    if (_direction > 0) {
      if (_timer >= frameCount) {
        _timer -= frameCount;
      }
    } else {
      if (_timer < 0) {
        _timer += frameCount;
      }
    }

    _index = _timer.toInt();
    texture = currentAnimation.frames[_actualIndex(frameCount)];
  }

  void _updatePingPong(double deltaTime) {
    final frameCount = currentAnimation.frames.length;
    _timer += _direction * currentAnimation.speed * deltaTime;

    if (_direction > 0) {
      if (_timer >= frameCount - 1) {
        _timer = (frameCount - 1) - (_timer - (frameCount - 1));
        _direction = -1;
      }
    } else {
      if (_timer < 0) {
        _timer = -_timer;
        _direction = 1;
      }
    }

    _index = _timer.toInt();
    texture = currentAnimation.frames[_actualIndex(frameCount)];
  }

  void setAnimation(String name, {int? fromFrame}) {
    if (_state == name) return;
    resetAnimation(name, fromFrame: fromFrame);
  }

  void resetAnimation(String name, {int? fromFrame}) {
    paused = false;
    _state = name;
    _direction = reverse ? -1 : 1;

    if (fromFrame != null) {
      index = fromFrame;
    } else if (reverse) {
      index = currentAnimation.frames.length - 1;
    } else {
      index = 0;
    }
  }
}
