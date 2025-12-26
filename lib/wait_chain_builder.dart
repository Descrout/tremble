import 'package:tremble/utils/types.dart';
import 'package:tremble/wait_events.dart';

class WaitChainBuilder {
  final WaitEvents _waitEvents;
  WaitChainBuilder(this._waitEvents);

  final _chain = <_ChainData>[];

  WaitChainBuilder wait(double time) {
    _chain.add(_ChainData.wait(time));
    return this;
  }

  WaitChainBuilder periodic(double time, PeriodicCallback onTick) {
    _chain.add(_ChainData.periodic(time, onTick));
    return this;
  }

  WaitChainBuilder waitUntil(UpdateSubscriptionCallback onUpdate) {
    _chain.add(_ChainData.waitUntil(onUpdate));
    return this;
  }

  WaitChainBuilder waitAndDo(double time, TimeUpdateCallback onUpdate) {
    _chain.add(_ChainData.waitAndDo(time, onUpdate));
    return this;
  }

  WaitChainBuilder run(VoidCallback fn) {
    _chain.add(_ChainData.run(fn));
    return this;
  }

  WaitChainBuilder blockUntil(void Function(VoidCallback fn) continueFn) {
    _chain.add(_ChainData.blockUntil(continueFn));
    return this;
  }

  VoidCallback _chainIt(int index) {
    if (index >= _chain.length) {
      return () {};
    }

    final onEnd = _chainIt(index + 1);

    switch (_chain[index]) {
      case _Run(fn: final fn):
        return () => _waitEvents.wait(
            time: 0,
            onEnd: () {
              fn();
              onEnd();
            });
      case _BlockUntil(continueFn: final continueFn):
        return () => continueFn(onEnd);
      case _Wait(time: final time):
        return () => _waitEvents.wait(time: time, onEnd: onEnd);
      case _Periodic(time: final time, onTick: final onTick):
        return () => _waitEvents.periodic(time: time, onTick: onTick, onEnd: onEnd);
      case _WaitUntil(onUpdate: final onUpdate):
        return () => _waitEvents.waitUntil(onUpdate: onUpdate, onEnd: onEnd);
      case _WaitAndDo(time: final time, onUpdate: final onUpdate):
        return () => _waitEvents.waitAndDo(time: time, onUpdate: onUpdate, onEnd: onEnd);
    }
  }

  void build() {
    if (_chain.isEmpty) return;
    _chainIt(0)();
  }
}

sealed class _ChainData {
  _ChainData();

  factory _ChainData.wait(double time) = _Wait;
  factory _ChainData.periodic(double time, PeriodicCallback onTick) = _Periodic;
  factory _ChainData.waitUntil(UpdateSubscriptionCallback onUpdate) = _WaitUntil;
  factory _ChainData.waitAndDo(double time, TimeUpdateCallback onUpdate) = _WaitAndDo;

  factory _ChainData.blockUntil(void Function(VoidCallback fn) continueFn) = _BlockUntil;

  factory _ChainData.run(VoidCallback fn) = _Run;
}

class _Wait extends _ChainData {
  final double time;
  _Wait(this.time);
}

class _Periodic extends _ChainData {
  final double time;
  final PeriodicCallback onTick;
  _Periodic(this.time, this.onTick);
}

class _WaitUntil extends _ChainData {
  final UpdateSubscriptionCallback onUpdate;
  _WaitUntil(this.onUpdate);
}

class _WaitAndDo extends _ChainData {
  final double time;
  final TimeUpdateCallback onUpdate;
  _WaitAndDo(this.time, this.onUpdate);
}

class _Run extends _ChainData {
  final VoidCallback fn;
  _Run(this.fn);
}

class _BlockUntil extends _ChainData {
  final void Function(VoidCallback fn) continueFn;
  _BlockUntil(this.continueFn);
}
