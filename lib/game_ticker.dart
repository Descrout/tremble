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

class _GameTickerState extends State<GameTicker> with SingleTickerProviderStateMixin {
  Ticker? ticker;
  int beforeMS = 0;

  final GameListener listener = GameListener();

  @override
  void initState() {
    widget.controller.setup(context, widget.width, widget.height);
    widget.controller.update(0);

    ticker = createTicker(tick);
    ticker!.start();

    super.initState();
  }

  void tick(Duration elapsed) {
    final elapsedMS = elapsed.inMilliseconds;
    final dt = (elapsedMS - beforeMS) / 1000;
    beforeMS = elapsedMS;
    widget.controller.update(dt);
    listener.update();
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
      oldWidget.controller.dispose();
      widget.controller.setup(context, widget.width, widget.height);
    }
    if (oldWidget.width != widget.width || oldWidget.height != widget.height) {
      widget.controller.resize(widget.width, widget.height);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.controller.dispose();
    listener.dispose();
    ticker?.dispose();
    super.dispose();
  }
}
