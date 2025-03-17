import 'package:flutter/material.dart';
import 'package:tremble/signal.dart';
import 'package:tremble/utils/types.dart';

class SignalBuilder<T> extends StatefulWidget {
  const SignalBuilder({super.key, required this.builder, required this.signal, this.onSignal});

  final Signal<T> signal;

  /// If you return true it will rebuild the widget
  /// If you return false it won't rebuild the widget, and it will stop listening to the signal
  /// If you return null it won't rebuild the widget, but it will still listen to the signal
  final SubscriptionCallback<T>? onSignal;

  final Widget Function(BuildContext context, T? value) builder;

  @override
  State<SignalBuilder<T>> createState() => _SignalBuilderState<T>();
}

class _SignalBuilderState<T> extends State<SignalBuilder<T>> {
  T? stateValue;

  bool? onSignal(T value) {
    final result = widget.onSignal?.call(value);

    if (result == false) {
      return false;
    } else if (result == true) {
      stateValue = value;
      setState(() {});
    }

    return true;
  }

  @override
  void initState() {
    widget.signal.listen(onSignal);
    super.initState();
  }

  @override
  void dispose() {
    widget.signal.unlisten(onSignal);
    stateValue = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, stateValue);
  }
}

class SignalsBuilder extends StatefulWidget {
  const SignalsBuilder({super.key, required this.builder, required this.signals, this.onSignal});

  final List<Signal> signals;
  final VoidCallback? onSignal;
  final Widget Function(BuildContext context) builder;

  @override
  State<SignalsBuilder> createState() => _SignalsBuilderState();
}

class _SignalsBuilderState extends State<SignalsBuilder> {
  bool? onSignal(value) {
    widget.onSignal?.call();
    setState(() {});
    return true;
  }

  @override
  void initState() {
    for (final signal in widget.signals) {
      signal.listen(onSignal);
    }

    super.initState();
  }

  @override
  void dispose() {
    for (final signal in widget.signals) {
      signal.unlisten(onSignal);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
