import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tremble/tremble.dart';
import 'package:tremble/utils/signal_value.dart';
import 'package:tremble_example/examples/bouncing_balls_example.dart';
import 'package:tremble_example/examples/camera_tilemap.dart';
import 'package:tremble_example/examples/collision_detection_example.dart';
import 'package:tremble_example/examples/discrete_collision_example.dart';
import 'package:tremble_example/examples/falling_sand_example.dart';
import 'package:tremble_example/examples/grid_raycaster_example.dart';
import 'package:tremble_example/examples/input_example.dart';
import 'package:tremble_example/examples/mario_movement_example.dart';
import 'package:tremble_example/examples/rigidbody_example.dart';
import 'package:tremble_example/examples/shape_raycaster_example.dart';
import 'package:tremble_example/examples/spritebatch_example.dart';
import 'package:tremble_example/examples/swept_collision_example.dart';
import 'package:tremble_example/examples/tile_map_example.dart';
import 'package:url_launcher/url_launcher.dart';

enum ExampleType { rendering, tooling, utility, physics, demo }

const exampleGroups = <ExampleType>[
  ExampleType.physics,
  ExampleType.demo,
  ExampleType.rendering,
  ExampleType.utility,
  ExampleType.tooling,
];

class ExampleItem {
  final String title;
  final String description;
  final ExampleType type;
  final String codeUrl;

  final ScreenController Function() screen;

  ExampleItem({
    required this.title,
    required this.description,
    required this.type,
    required this.codeUrl,
    required this.screen,
  });
}

final examples = <ExampleItem>[
  ExampleItem(
    title: "Bouncing Balls",
    description: "A classic bouncing balls example.",
    type: ExampleType.demo,
    codeUrl:
        "https://github.com/Descrout/tremble/blob/main/example/lib/examples/bouncing_balls_example.dart",
    screen: () => BouncingBallsExample(),
  ),
  ExampleItem(
    title: "Basic Collision Detection",
    description: "Left and Right click to change shapes.",
    type: ExampleType.physics,
    codeUrl:
        "https://github.com/Descrout/tremble/blob/main/example/lib/examples/collision_detection_example.dart",
    screen: () => CollisionDetectionExample(),
  ),
  ExampleItem(
    title: "Discrete Collision Response",
    description: "*Minkowski* difference resolution. Left and Right click to change shapes.",
    type: ExampleType.physics,
    codeUrl:
        "https://github.com/Descrout/tremble/blob/main/example/lib/examples/discrete_collision_example.dart",
    screen: () => DiscreteCollisionExample(),
  ),
  ExampleItem(
    title: "Swept Collision Response",
    description: "Swept collision resolution using *Sweep* and *Ray* classes. Fixes tunneling.",
    type: ExampleType.physics,
    codeUrl:
        "https://github.com/Descrout/tremble/blob/main/example/lib/examples/swept_collision_example.dart",
    screen: () => SweptCollisionExample(),
  ),
  ExampleItem(
    title: "Rigidbody",
    description: "Move your mouse to guide one circle along other circle rigidbodies.",
    type: ExampleType.physics,
    codeUrl:
        "https://github.com/Descrout/tremble/blob/main/example/lib/examples/rigidbody_example.dart",
    screen: () => RigidBodyExample(),
  ),
  ExampleItem(
    title: "Input Handling",
    description: "Handle *keyboard* and *mouse/touch* inputs.",
    type: ExampleType.utility,
    codeUrl:
        "https://github.com/Descrout/tremble/blob/main/example/lib/examples/input_example.dart",
    screen: () => InputExample(),
  ),
  ExampleItem(
    title: "SpriteBatch",
    description: "Efficiently draw a lot of *Sprite* and *Animation* objects.",
    type: ExampleType.rendering,
    codeUrl:
        "https://github.com/Descrout/tremble/blob/main/example/lib/examples/spritebatch_example.dart",
    screen: () => SpritebatchExample(),
  ),
  ExampleItem(
    title: "Mario Movement",
    description:
        "Platformer movement using *Animation* and *StateMachine*, Use arrow keys to move.",
    type: ExampleType.demo,
    codeUrl:
        "https://github.com/Descrout/tremble/blob/main/example/lib/examples/mario_movement_example.dart",
    screen: () => MarioMovementExample(),
  ),
  ExampleItem(
    title: "Simple Level Editor",
    description: "Simple in-game level editor using *TileMap* and *Grid*.",
    type: ExampleType.demo,
    codeUrl:
        "https://github.com/Descrout/tremble/blob/main/example/lib/examples/tile_map_example.dart",
    screen: () => TileMapExample(),
  ),
  ExampleItem(
    title: "Camera and TileMap",
    description: "Efficient *TileMap* rendering using *Camera* as cull area.",
    type: ExampleType.rendering,
    codeUrl:
        "https://github.com/Descrout/tremble/blob/main/example/lib/examples/camera_tilemap.dart",
    screen: () => CameraTilemap(),
  ),
  ExampleItem(
    title: "Falling Sand Simulation",
    description: "Click on screen to put sands in this *cellular automata* example.",
    type: ExampleType.demo,
    codeUrl:
        "https://github.com/Descrout/tremble/blob/main/example/lib/examples/falling_sand_example.dart",
    screen: () => FallingSandExample(),
  ),
  ExampleItem(
    title: "Shape Raycaster",
    description: "Use *Raycaster* to cast rays towards 2D shapes.",
    type: ExampleType.physics,
    codeUrl:
        "https://github.com/Descrout/tremble/blob/main/example/lib/examples/shape_raycaster_example.dart",
    screen: () => ShapeRaycasterExample(),
  ),
  ExampleItem(
    title: "Grid Raycaster",
    description: "*Grid* (DDA) raycasting.",
    type: ExampleType.physics,
    codeUrl:
        "https://github.com/Descrout/tremble/blob/main/example/lib/examples/grid_raycaster_example.dart",
    screen: () => GridRaycasterExample(),
  ),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await BrowserContextMenu.disableContextMenu();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final exampleIndex = SignalValue<int>(0);
  late final Set<ExampleType> _collapsedGroups;

  @override
  void initState() {
    super.initState();
    _collapsedGroups = {
      for (final group in exampleGroups)
        if (_groupCount(group) > 0 && group != examples[0].type) group,
    };
  }

  int _groupCount(ExampleType group) => examples.where((e) => e.type == group).length;

  void _toggleGroup(ExampleType group) {
    setState(() {
      if (!_collapsedGroups.remove(group)) {
        _collapsedGroups.add(group);
      }
    });
  }

  void _selectExample(int index) {
    exampleIndex.value = index;
    setState(() => _collapsedGroups.remove(examples[index].type));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tremble Examples',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0f0f1a),
      ),
      home: Scaffold(
        body: Focus(
          canRequestFocus: false,
          descendantsAreFocusable: false,
          child: SignalValueBuilder(
            value: exampleIndex,
            builder: (context, child, index) {
              return Row(
                children: [
                  _buildSidebar(index),
                  const VerticalDivider(width: 1, color: Color(0xFF2a2a3e)),
                  Expanded(child: _buildGamePanel(index)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(int selectedIndex) {
    return SizedBox(
      width: 360,
      child: Container(
        color: const Color(0xFF14142a),
        child: Column(
          children: [
            _buildSidebarHeader(),
            const Divider(height: 1, color: Color(0xFF2a2a3e)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  for (final group in exampleGroups)
                    if (_groupCount(group) > 0) ..._buildGroupItems(group, selectedIndex),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupItems(ExampleType group, int selectedIndex) {
    final widgets = <Widget>[_buildGroupHeader(group)];
    if (!_collapsedGroups.contains(group)) {
      for (var i = 0; i < examples.length; i++) {
        if (examples[i].type == group) {
          widgets.add(_buildExampleItem(examples[i], i == selectedIndex, i));
        }
      }
    }
    return widgets;
  }

  Widget _buildGroupHeader(ExampleType group) {
    final collapsed = _collapsedGroups.contains(group);
    final typeColor = _typeColor(group);
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8, left: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _toggleGroup(group),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Icon(
                collapsed ? Icons.expand_more : Icons.expand_less,
                size: 18,
                color: typeColor,
              ),
              const SizedBox(width: 8),
              Text(
                group.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_groupCount(group)}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: typeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              "assets/tremble_logo.jpeg",
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tremble Examples",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[100],
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "v1.2.8",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => launchUrl(Uri.parse("https://tremble-docs.netlify.app")),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Icon(Icons.menu_book, size: 18, color: Colors.grey[400]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleItem(ExampleItem example, bool selected, int index) {
    final typeColor = _typeColor(example.type);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectExample(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1e1e3f) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? typeColor.withValues(alpha: 0.5) : const Color(0xFF2a2a3e),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _typeIcon(example.type, typeColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            example.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              color: Colors.grey[100],
                            ),
                          ),
                        ),
                        _typeChip(example.type, typeColor),
                      ],
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400],
                          height: 1.4,
                        ),
                        children: _parseDescription(
                          example.description,
                          highlightColor: typeColor,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGamePanel(int index) {
    final example = examples[index];
    return Column(
      children: [
        _buildGameHeader(example),
        const Divider(height: 1, color: Color(0xFF2a2a3e)),
        Expanded(
          child: FittedBox(
            child: Container(
              width: 800,
              height: 600,
              margin: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: GameArea(controller: example.screen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameHeader(ExampleItem example) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      color: const Color(0xFF14142a),
      child: Row(
        children: [
          IconButton(
            onPressed: () => launchUrl(Uri.parse(example.codeUrl)),
            icon: Icon(Icons.code, color: Colors.cyan[400]),
            tooltip: "View Code",
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  example.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[400],
                      height: 1.3,
                    ),
                    children: _parseDescription(
                      example.description,
                      highlightColor: Colors.cyan[400]!,
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => launchUrl(Uri.parse(example.codeUrl)),
            icon: Icon(Icons.code, size: 18, color: Colors.cyan[400]),
            label: Text(
              "View Code",
              style: TextStyle(fontSize: 14, color: Colors.cyan[400]),
            ),
          ),
        ],
      ),
    );
  }

  Color _typeColor(ExampleType type) {
    return switch (type) {
      ExampleType.rendering => Colors.purple[400]!,
      ExampleType.tooling => Colors.teal[400]!,
      ExampleType.utility => Colors.blue[400]!,
      ExampleType.physics => Colors.red[400]!,
      ExampleType.demo => Colors.green[400]!,
    };
  }

  Widget _typeIcon(ExampleType type, Color color, {double size = 32}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        switch (type) {
          ExampleType.rendering => Icons.image,
          ExampleType.tooling => Icons.build,
          ExampleType.utility => Icons.handyman,
          ExampleType.physics => Icons.bolt,
          ExampleType.demo => Icons.play_circle,
        },
        size: size * 0.55,
        color: color,
      ),
    );
  }

  Widget _typeChip(ExampleType type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        type.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  List<InlineSpan> _parseDescription(String text, {required Color highlightColor}) {
    final spans = <InlineSpan>[];
    final parts = text.split('*');
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      if (i.isOdd) {
        spans.add(TextSpan(
          text: parts[i],
          style: TextStyle(
            color: highlightColor,
            fontWeight: FontWeight.w600,
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: parts[i],
          style: TextStyle(color: Colors.grey[400]),
        ));
      }
    }
    return spans;
  }

  @override
  void dispose() {
    exampleIndex.dispose();
    super.dispose();
  }
}
