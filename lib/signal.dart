import 'dart:collection';

import 'package:tremble/utils/types.dart';

class Signal<T> {
  final LinkedHashSet<SubscriptionCallback<T>> _subs = LinkedHashSet();

  int get length => _subs.length;

  bool get hasListeners => _subs.isNotEmpty;

  void clear() => _subs.clear();

  void listen(SubscriptionCallback<T> callback) {
    _subs.add(callback);
  }

  void unlisten(SubscriptionCallback<T> callback) {
    _subs.remove(callback);
  }

  void dispatch(T args) {
    final callbacks = List<SubscriptionCallback<T>>.of(_subs);

    for (final callback in callbacks) {
      if (!_subs.contains(callback)) {
        continue;
      }

      final keepListening = callback(args);

      if (keepListening != true) {
        _subs.remove(callback);
      }
    }
  }
}
