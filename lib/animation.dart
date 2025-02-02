import 'dart:ui';

import 'package:tremble/sprite.dart';

class AnimationData {
  AnimationData({
    required this.key,
    required this.frames,
    required this.speed,
    required this.loop,
  });

  final String key;
  final List<Rect> frames;
  final double speed;
  final bool loop;
}

class Animation extends Sprite {
  Animation({
    required List<AnimationData> animations,
    required super.x,
    required super.y,
    int index = 0,
    super.originX = 0.5,
    super.originY = 0.5,
    super.opacity = 255,
    super.scale = 1.0,
    super.rotation = 0,
  })  : assert(animations.isNotEmpty, "you have to provide atleast 1 AnimationData"),
        _index = index,
        _timer = index.toDouble(),
        _animations = Map.fromEntries(animations.map((e) => MapEntry(e.key, e))),
        _state = animations.first.key,
        super(texture: animations.first.frames[index]);

  final Map<String, AnimationData> _animations;

  bool playing = true;
  bool finished = false;
  String _state;
  double _timer;

  AnimationData get currentAnimData => _animations[_state]!;

  int _index;
  int get index => _index;
  set index(int val) {
    _index = val;
    _timer = val.toDouble();
  }

  void update(double deltaTime) {
    if (!playing) return;
    finished = false;

    if (_index < 0) {
      index = 0;
      if (currentAnimData.loop) {
        index = currentAnimData.frames.length - 1;
      } else {
        index = 0;
        finished = true;
      }
    } else if (_index >= currentAnimData.frames.length) {
      if (currentAnimData.loop) {
        index = 0;
      } else {
        index = currentAnimData.frames.length - 1;
        finished = true;
      }
    } else {
      _timer += currentAnimData.speed * deltaTime;
    }

    texture = currentAnimData.frames[_index];
    _index = _timer.toInt();
  }

  void setAnimation(String state, {int? fromFrame}) {
    if (_state == state) return;
    resetAnimation(state, fromFrame: fromFrame);
  }

  void resetAnimation(String state, {int? fromFrame}) {
    playing = true;
    _state = state;
    if (fromFrame != null) {
      index = fromFrame;
    }
  }
}
