import 'package:tremble/utils/signal.dart';

class SignalValue<T> {
  final Signal<T> signal;

  T _value;
  T get value => _value;
  set value(T val) {
    if (val == _value || _disposed) return;
    signal.dispatch(_value);
  }

  bool _disposed = false;

  SignalValue(this._value) : signal = Signal<T>() {
    signal.listen((T val) {
      _value = val;
      return !_disposed;
    });
  }

  void dispose() {
    _disposed = true;
    signal.clear();
  }
}
