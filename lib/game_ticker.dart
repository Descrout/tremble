import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:tremble/game_listener.dart';
import 'package:tremble/game_painter.dart';
import 'package:tremble/screen_controller.dart';

class GameTicker extends StatefulWidget {
  const GameTicker({
    super.key,
    required this.controller,
    required this.width,
    required this.height,
  });

  final ScreenController controller;
  final double width;
  final double height;

  @override
  State<GameTicker> createState() => _GameTickerState();
}

class _GameTickerState extends State<GameTicker>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Ticker? ticker;
  int beforeMS = 0;

  final GameListener listener = GameListener();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    widget.controller.setup(context, widget.width, widget.height);
    widget.controller.update(0);

    ticker = createTicker(tick);
    ticker!.start();

    super.initState();
  }

  void tick(Duration elapsed) {
    final elapsedMS = elapsed.inMicroseconds;
    final deltaTime = ((elapsedMS - beforeMS) / 1e6).clamp(0.0, 0.05);

    beforeMS = elapsedMS;

    widget.controller.update(deltaTime);
    listener.update();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.controller.lifecycleChanged(state);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        isComplex: true,
        painter: GamePainter(controller: widget.controller, listener: listener),
        child: SizedBox(width: widget.width, height: widget.height),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant GameTicker oldWidget) {
    if (oldWidget.controller != widget.controller) {
      widget.controller.setup(context, widget.width, widget.height);
    }
    if (oldWidget.width != widget.width || oldWidget.height != widget.height) {
      widget.controller.resized(widget.width, widget.height);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    listener.dispose();
    ticker?.dispose();
    super.dispose();
  }
}
