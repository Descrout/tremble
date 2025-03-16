import 'package:flutter/material.dart';
import 'package:tremble/signal.dart';
import 'package:tremble/utils/types.dart';

class SignalBuilder<T> extends StatefulWidget {
  const SignalBuilder(
      {super.key, required this.builder, required this.signal, required this.onSignal});

  final Signal<T> signal;
  final SubscriptionCallback<T> onSignal;
  final Widget Function(BuildContext context, T? value) builder;

  @override
  State<SignalBuilder> createState() => _SignalBuilderState();
}

class _SignalBuilderState<T> extends State<SignalBuilder<T>> {
  T? stateValue;

  bool? onSignal(T value) {
    final result = widget.onSignal(value);

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
