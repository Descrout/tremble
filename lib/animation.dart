import 'dart:ui';

import 'package:tremble/sprite.dart';

class AnimationData {
  AnimationData({
    required this.frames,
    required this.speed,
    required this.loop,
  });

  final List<Rect> frames;
  final double speed;
  final bool loop;
}

class Animation extends Sprite {
  Animation({
    required this.animations,
    required this.state,
    required super.x,
    required super.y,
    int index = 0,
    super.originX = 0.5,
    super.originY = 0.5,
    super.opacity = 1.0,
    super.scale = 1.0,
    super.rotation = 0,
  })  : _index = index,
        _timer = index.toDouble(),
        super(texture: animations[state]!.frames[index]);

  final Map<String, AnimationData> animations;

  bool playing = true;
  bool halted = false;
  String state;
  double _timer;

  AnimationData get currentAnimData => animations[state]!;

  int _index;
  int get index => _index;
  set index(int val) {
    _index = val;
    _timer = val.toDouble();
  }

  void update(double deltaTime) {
    if (!playing) return;
    halted = false;

    if (_index < 0) {
      index = 0;
      if (currentAnimData.loop) {
        index = currentAnimData.frames.length - 1;
      } else {
        index = 0;
        halted = true;
      }
    } else if (_index >= currentAnimData.frames.length) {
      if (currentAnimData.loop) {
        index = 0;
      } else {
        index = currentAnimData.frames.length - 1;
        halted = true;
      }
    } else {
      _timer += currentAnimData.speed * deltaTime;
    }

    texture = currentAnimData.frames[_index];
    _index = _timer.toInt();
  }

  void setAnimation(String state, {int? fromFrame}) {
    if (this.state == state) return;
    resetAnimation(state, fromFrame: fromFrame);
  }

  void resetAnimation(String state, {int? fromFrame}) {
    playing = true;
    this.state = state;
    if (fromFrame != null) {
      index = fromFrame;
    }
  }
}
