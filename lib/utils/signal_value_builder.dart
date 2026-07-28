import 'package:flutter/material.dart';
import 'package:tremble/utils/signal_value.dart';
import 'package:tremble/utils/types.dart';

class SignalValueBuilder<T> extends StatefulWidget {
  const SignalValueBuilder({
    super.key,
    required this.builder,
    required this.value,
    this.child,
    this.onSignal,
  });

  final SignalValue<T> value;

  /// Return values:
  ///
  /// true  -> rebuild and keep listening
  /// false -> stop listening
  /// null  -> keep listening without rebuilding
  final SubscriptionCallback<T>? onSignal;

  final Widget Function(BuildContext context, Widget? child, T value) builder;

  final Widget? child;

  @override
  State<SignalValueBuilder<T>> createState() => _SignalValueBuilderState<T>();
}

class _SignalValueBuilderState<T> extends State<SignalValueBuilder<T>> {
  bool? _onSignal(T value) {
    if (!mounted) return false;

    final result = widget.onSignal?.call(value);

    if (result == false) {
      return false;
    }

    if (result == null && widget.onSignal != null) {
      return true;
    }

    setState(() {});

    return true;
  }

  @override
  void initState() {
    super.initState();
    widget.value.signal.listen(_onSignal);
  }

  @override
  void didUpdateWidget(covariant SignalValueBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      oldWidget.value.signal.unlisten(_onSignal);
      widget.value.signal.listen(_onSignal);
    }
  }

  @override
  void dispose() {
    widget.value.signal.unlisten(_onSignal);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.child, widget.value.value);
  }
}
