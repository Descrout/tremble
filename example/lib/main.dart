import 'package:flutter/material.dart';
import 'package:tremble/game_area.dart';
import 'package:tremble_example/demo_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tremble Demo',
      home: FittedBox(
        child: SizedBox(
          width: 480,
          height: 640,
          child: GameArea(
            controller: DemoController(),
          ),
        ),
      ),
    );
  }
}
