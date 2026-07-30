class FixedUpdate {
  double _accumulator = 0;
  double _fixedDeltaTime;
  int _fps;

  final Function(double) _onUpdate;

  FixedUpdate(this._fps, {required Function(double fixedDeltaTime) onUpdate})
      : assert(_fps > 0, "fps must be positive"),
        _fixedDeltaTime = 1 / _fps,
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
