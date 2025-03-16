import 'package:tremble/utils/types.dart';

class Signal<T> {
  final _subs = <SubscriptionCallback<T>>[];

  int get length => _subs.length;

  void clear() => _subs.clear();

  void listen(SubscriptionCallback<T> callback) => _subs.add(callback);
  void unlisten(SubscriptionCallback<T> callback) => _subs.remove(callback);

  void dispatch(T args) {
    for (int i = _subs.length - 1; i >= 0; i--) {
      final keep = _subs[i](args);
      if (keep != true) _subs.removeAt(i);
    }
  }
}
