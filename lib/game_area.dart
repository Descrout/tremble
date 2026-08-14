import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tremble/game_ticker.dart';
import 'package:tremble/screen_controller.dart';

class GameArea extends StatefulWidget {
  const GameArea({
    super.key,
    required this.controller,
    this.loadingBuilder,
  });

  final ScreenController controller;
  final Widget Function(BuildContext context, double progress)? loadingBuilder;

  @override
  State<GameArea> createState() => _GameAreaState();
}

class _GameAreaState extends State<GameArea> {
  StreamController<double>? preloadStream;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    ServicesBinding.instance.keyboard.addHandler(_onKey);
    _preload();
  }

  int _preloadGeneration = 0;

  void _preload() {
    final generation = ++_preloadGeneration;

    preloadStream?.close();
    preloadStream = StreamController<double>();

    loaded = false;

    widget.controller.preload(
      (progress) {
        if (generation == _preloadGeneration) {
          preloadStream?.sink.add(progress);
        }
      },
      () {
        if (generation != _preloadGeneration || !mounted) return;

        loaded = true;
        preloadStream?.close();
        preloadStream = null;

        setState(() {});
      },
    );
  }

  @override
  void didUpdateWidget(covariant GameArea oldWidget) {
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.dispose();
      _preload();
    }

    super.didUpdateWidget(oldWidget);
  }

  bool _onKey(KeyEvent event) {
    final key = event.logicalKey;

    if (event is KeyDownEvent) {
      widget.controller.keyDown(key);
    } else if (event is KeyUpEvent) {
      widget.controller.keyUp(key);
    } else if (event is KeyRepeatEvent) {
      widget.controller.keyRepeat(key);
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return loaded
        ? ClipRRect(
            child: Listener(
              onPointerDown: (event) => widget.controller.mousePressed(
                  event.pointer, event.buttons, event.localPosition.dx, event.localPosition.dy),
              onPointerUp: (event) => widget.controller.mouseReleased(event.pointer),
              onPointerHover: (event) => widget.controller
                  .mouseMove(event.pointer, event.localPosition.dx, event.localPosition.dy),
              onPointerMove: (event) => widget.controller
                  .mouseMove(event.pointer, event.localPosition.dx, event.localPosition.dy),
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) widget.controller.mouseScroll(event.scrollDelta);
              },
              child: LayoutBuilder(builder: (context, constraints) {
                return GameTicker(
                  controller: widget.controller,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                );
              }),
            ),
          )
        : StreamBuilder<double>(
            stream: preloadStream?.stream,
            builder: (context, snapshot) {
              return widget.loadingBuilder?.call(context, snapshot.data ?? 0.0) ?? const SizedBox();
            },
          );
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    widget.controller.dispose();
    preloadStream?.close();
    preloadStream = null;
    super.dispose();
  }
}
