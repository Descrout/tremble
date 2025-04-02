import 'dart:io';

import 'package:flutter/foundation.dart';
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
    final controller = DemoController();

    return MaterialApp(
      title: 'Tremble Demo',
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: FittedBox(
                child: SizedBox(
                  width: 480,
                  height: 640,
                  child: GameArea(
                    controller: controller,
                  ),
                ),
              ),
            ),
            if (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux)
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Keyboard Mode"),
                            ValueListenableBuilder<bool>(
                                valueListenable: controller.isMouseControlled,
                                builder: (context, value, child) {
                                  return Focus(
                                    canRequestFocus: false,
                                    skipTraversal: true,
                                    descendantsAreFocusable: false,
                                    descendantsAreTraversable: false,
                                    child: Switch(
                                        value: value,
                                        onChanged: (isOn) {
                                          controller.isMouseControlled.value = isOn;
                                        }),
                                  );
                                }),
                            const Text("Mouse Mode"),
                          ],
                        ),
                        ValueListenableBuilder<bool>(
                            valueListenable: controller.isMouseControlled,
                            builder: (context, value, child) {
                              if (value) return const Text("Mouse Press");
                              return const Text("Left Arrow | Space | Right Arrow");
                            }),
                      ],
                    ),
                  ))
          ],
        ),
      ),
    );
  }
}
