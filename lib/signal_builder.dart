import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tremble/signal.dart';
import 'package:tremble/utils/types.dart';

class SignalBuilder<T> extends StatefulWidget {
  const SignalBuilder({
    super.key,
    required this.builder,
    required this.signal,
    this.onSignal,
  });

  final Signal<T> signal;

  /// Return values:
  ///
  /// true  -> rebuild and keep listening
  /// false -> stop listening
  /// null  -> keep listening without rebuilding
  final SubscriptionCallback<T>? onSignal;

  final Widget Function(BuildContext context, T? value) builder;

  @override
  State<SignalBuilder<T>> createState() => _SignalBuilderState<T>();
}

class _SignalBuilderState<T> extends State<SignalBuilder<T>> {
  T? stateValue;

  bool? _onSignal(T value) {
    if (!mounted) return false;

    final result = widget.onSignal?.call(value);

    if (result == false) {
      return false;
    }

    if (result == null && widget.onSignal != null) {
      return true;
    }

    stateValue = value;
    setState(() {});

    return true;
  }

  @override
  void initState() {
    super.initState();
    widget.signal.listen(_onSignal);
  }

  @override
  void didUpdateWidget(covariant SignalBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.signal != widget.signal) {
      oldWidget.signal.unlisten(_onSignal);
      widget.signal.listen(_onSignal);
    }
  }

  @override
  void dispose() {
    widget.signal.unlisten(_onSignal);
    stateValue = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, stateValue);
  }
}

class SignalsBuilder extends StatefulWidget {
  const SignalsBuilder({
    super.key,
    required this.builder,
    required this.signals,
    this.onSignal,
  });

  final List<Signal> signals;
  final VoidCallback? onSignal;
  final Widget Function(BuildContext context) builder;

  @override
  State<SignalsBuilder> createState() => _SignalsBuilderState();
}

class _SignalsBuilderState extends State<SignalsBuilder> {
  bool? _onSignal(dynamic value) {
    if (!mounted) return true;

    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      setState(() {});
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    for (final signal in widget.signals) {
      signal.listen(_onSignal);
    }
  }

  @override
  void didUpdateWidget(covariant SignalsBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    for (final signal in oldWidget.signals) {
      signal.unlisten(_onSignal);
    }

    for (final signal in widget.signals) {
      signal.listen(_onSignal);
    }
  }

  @override
  void dispose() {
    for (final signal in widget.signals) {
      signal.unlisten(_onSignal);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
