import 'package:tremble/types.dart';

class Signal<T> {
  final _subs = <SubscriptionCallback<T>>[];

  int get length => _subs.length;

  void clear() => _subs.clear();

  void listen(SubscriptionCallback<T> callback) => _subs.add(callback);

  void dispatch(T args) {
    for (int i = _subs.length - 1; i >= 0; i--) {
      final callback = _subs[i];
      final keep = callback(args);
      if (keep != true) _subs.removeAt(i);
    }
  }
}
