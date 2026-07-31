class FixedUpdate {
  double _accumulator = 0;
  double _fixedDeltaTime;
  int _fps;

  final Function(double) _onUpdate;

  FixedUpdate(int fps, {required void Function(double fixedDeltaTime) onUpdate})
      : assert(fps > 0, "fps must be positive"),
        _fps = fps,
        _fixedDeltaTime = 1 / fps,
        _onUpdate = onUpdate;

  int get fps => _fps;
  set fps(int value) {
    assert(value > 0, "fps must be positive");
    _fps = value;
    _fixedDeltaTime = 1 / _fps;
  }

  double get fixedDeltaTime => _fixedDeltaTime;

  void update(double deltaTime) {
    _accumulator += deltaTime;
    while (_accumulator >= _fixedDeltaTime) {
      _onUpdate(_fixedDeltaTime);
      _accumulator -= _fixedDeltaTime;
    }
  }
}
