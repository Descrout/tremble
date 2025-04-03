# Tremble
A simple "game engine" written in Flutter. It doesn’t enforce a complex structure; instead, it follows a straightforward setup/draw function pattern used by frameworks like p5.js, Processing, Raylib, LÖVE, Pico-8, and others.

## Usage
Use the `GameArea` widget with a `ScreenController`, and you are good to go.

This example shows how you can set a specific size for your game. By using `FittedBox` and `SizedBox` together, you can achieve a letterbox effect when the window does not match your desired aspect ratio.

```dart
FittedBox(
  child: SizedBox(
    width: 480,
    height: 640,
    child: GameArea(controller: DemoController()),
  )
)
```

### What is a ScreenController
A `ScreenController` is responsible for handling user input, loading assets, and rendering content on the screen. In its simplest form, it looks like this:

```dart
class DemoController extends ScreenController {
  @override
  void setup(BuildContext context, double width, double height) {
    // Runs once before the first frame is drawn
    // Provides access to the BuildContext, screen width, and height
  }

  @override
  void update(double deltaTime) {
    // Runs 60 times per second
    // Provides deltaTime for frame-independent calculations
    // Update game objects here
  }

  @override
  void draw(Canvas canvas, Size size) {
    // Runs 60 times per second
    // Provides a Flutter Canvas and screen size
    // Render content to the screen here
  }

  @override
  void dispose() {
    // Runs when the widget is removed from the widget tree
    // Clean up and dispose of assets here
  }
}
```

> Everything below consists of optional override functions inside the `ScreenController`.

### Keyboard Input
These functions trigger once per key input:

```dart
@override
void keyDown(LogicalKeyboardKey key) {
  if (key == LogicalKeyboardKey.arrowLeft) {
    // Left arrow key just pressed
  }
}

@override
void keyUp(LogicalKeyboardKey key) {
  if (key == LogicalKeyboardKey.space) {
    // Space key just released
  }
}
```

To check for continuous key presses (i.e., holding down a key), use a `Set` and check in the `update` function:

```dart
final keys = <LogicalKeyboardKey>{};

@override
void update(double deltaTime) {
  if (keys.contains(LogicalKeyboardKey.space)) {
    print("User is holding down the spacebar");
  }
}

@override
void keyDown(LogicalKeyboardKey key) {
  keys.add(key);
}

@override
void keyUp(LogicalKeyboardKey key) {
  keys.remove(key);
}
```

### Mouse Input
```dart
@override
void mouseMove(int pointerID, double mouseX, double mouseY) {
  // Called when the mouse moves over the GameArea
  // Provides mouse x and y positions
  // Pointer ID helps with multi-touch detection
}

@override
void mousePressed(int pointerID, int button, double mouseX, double mouseY) {
  // Called when a mouse button is pressed
  // Provides the button identifier and mouse position at press time
}

@override
void mouseReleased(int pointerID) {
  // Called when a mouse button is released
  // Pointer ID matches the initial press event
}

@override
void mouseScroll(Offset scrollOffset) {
  // Called when the mouse wheel is scrolled
  // Provides scroll offset for speed and direction detection
}
```

### Resize
If you use the `FittedBox` method, this function will never be called because the internal screen size remains the same. However, if you need a dynamic screen size, this function is triggered when the window is resized:

```dart
@override
void resize(double width, double height) {
}
```

### Preload
Since loading assets takes time, you can use the asynchronous `preload` function:

```dart
@override
Future<void> preload(progress, done) async {
  // await LoadImages()
  progress(0.25);
  // await LoadSounds()
  progress(0.50);
  // await LoadMaps()
  progress(0.75);
  // await GenerateLevel()
  progress(1.0);
  done(); // Call done() at the end
}
```

You can use `loadingBuilder` to display a loading screen while assets load:

```dart
GameArea(
  controller: DemoController(),
  loadingBuilder: (context, progress) {
    return Center(child: LinearProgressIndicator(value: progress));
  },
),
```

### SpriteBatch, Sprite, Animation
Using the `Canvas` object that is provided in the `draw` function, you can draw shapes, images, texts, etc. But you will eventually need to do animations. Tremble has `SpriteBatch`, `Sprite` and `Animation` helper classes for you.
#### SpriteBatch
Sprite batching optimizes rendering by reducing draw calls.

```dart
late final SpriteBatch spriteBatch;

@override
Future<void> preload(progress, done) async {
  spriteBatch = await SpriteBatch.fromOldGdxPacker("assets/batches/sprites.atlas", flippable: true);
  progress(1.0);
  done();
}
```

I primarily use [gdx-texture-packer](https://github.com/crashinvaders/gdx-texture-packer-gui) for texture packing. Recently, they updated the output format, so there are now two initialization functions:
- `SpriteBatch.fromOldGdxPacker` (for the previous format)
    
- `SpriteBatch.fromGdxPacker` (for the updated format)

Additionally, `SpriteBatch.custom` allows you to implement your own format. More implementations for different tools are planned, and contributions are welcome!

- **Textures**: Call `spriteBatch.getTexture("texture_name")` to get a `Rect` object, which represents a portion of the atlas image.
    
- **Animations**: Call `spriteBatch.getAnimation("hero-idle", speed: 10)` to get `AnimationData`, a list of `Rect` objects with animation details like `speed` and `loop`.
    
- **Usage**: Use `getTexture` with `Sprite` objects and `getAnimation` with `Animation` objects.

#### Using with Sprite
```dart
final table = Sprite(texture: spriteBatch.getTexture("table"), x: 100, y: 100);
table.originX = 0.5;
table.originY = 0.5;
table.opacity = 255;
table.scale = 1.0;
table.rotation = 0;
table.flip = false;
table.tint = Colors.white;
```

#### Using with Animation
Animations are essentially `Sprite` objects with additional animation functionality, meaning you can use `Sprite` properties on them.
```dart
final hero = Animation(
  animations: [
    spriteBatch.getAnimation("hero-idle", speed: 10),
    spriteBatch.getAnimation("hero-run", speed: 10),
  ],
  x: width / 2,
  y: height - 26,
);

// Sprite properties
hero.originX = 0.5;
hero.originY = 0.5;
hero.opacity = 255;
hero.scale = 1.0;
hero.rotation = 0;
hero.flip = false;
hero.tint = Colors.white;
```
Unlike `Sprite` objects, `Animation` objects need to be updated to play.
```dart
hero.update(deltaTime);
```
Since `Animation` accepts a list of animations, you can switch between them dynamically:
```dart
// When not moving
hero.setAnimation("hero-idle");

// When moving
hero.setAnimation("hero-run", fromFrame: 0);

// Flip direction based on movement
hero.flip = isMovingLeft;
```

#### Drawing `Sprite` and `Animation` Objects
```dart
spriteBatch.draw(canvas, [hero, table]);
```
Both `hero` and `table` will be drawn at their respective `.x` and `.y` positions with their properties. The `SpriteBatch.draw` function takes a canvas and a list of `Sprite` objects. Since `Animation` extends `Sprite`, it works seamlessly.

## Helpers
### Signal
Signals are similar to `Stream` in Flutter. They are a more lightweight version of streams. If you are familiar with Godot game engine Signals, this is basically the same thing.
```dart
final heroTookDamage = Signal<int>();
```
You define a `Signal` object with a type, and many systems can listen to this signal.
```dart
// For example, an HP bar system might use this signal to update state
heroTookDamage.listen((damage) {
  hpBar -= damage;
  return true;
});
```
```dart
// A damage UI system will make text appear on player when damage is taken
heroTookDamage.listen((damage) {
  damageUi.showDamageTaken(damage);
  return true;
});
```
As long as you return true from these callback functions, the listen function will keep listening to the `Signal`. If you return false, then listening will stop.
```dart
// Stop listening to the signal when the player dies
heroTookDamage.listen((damage) {
  hpBar -= damage;
  return hpBar > 0;
});
```
And this is how you trigger a `Signal`:
```dart
// All the listeners of this Signal will be notified
// Hero took 5 damage
heroTookDamage.dispatch(5);
```
You can clear all the listeners with:
```dart
heroTookDamage.clear();
```
There is also a `SignalBuilder` widget if you want to update a Flutter widget based on a `Signal`.
```dart
SignalBuilder(
  signal: controller.heroTookDamage,
  builder: (context, damage) {
    return Text("Last damage taken: $damage");
  },
),
```
### Wait Events
You can use `WaitEvents` to run code at a later time. It has more functionality than `Timer`.
```dart
// Create a WaitEvents object
final wait = WaitEvents();
// Update in your game loop
wait.update(deltaTime);
```
##### wait
```dart
wait.wait(
  time: 1.5,
  onEnd: () {
    // This callback will be called after 1.5 seconds
  },
);
```
##### waitAndDo
```dart
wait.waitAndDo(
  time: 2,
  onUpdate: (deltaTime, remainingTime) {
    // This callback will run like an enclosed mini update function
    // It provides you a deltaTime and remainingTime in seconds
    // This will continuously run for 2 seconds and will stop running
  },
  onEnd: () { // Optional
    // This callback will be called after 2 seconds
  },
);
```
##### waitUntil
```dart
wait.waitUntil(onUpdate: (deltaTime) {
  // Enclosed mini update function
  // If you return false, this callback will stop running
  return true;
}, onEnd: () {
  // After the onUpdate ends, this will be called once
});
```
### State Machine
```dart
// Create a StateMachine object
final stateMachine = StateMachine();
// Update in your game loop
stateMachine.update(deltaTime);
```
Add state:
```dart
stateMachine.add(
  "walking",
  onEnter: () {
    // Calls when state machine enters "walking" state
  },
  onUpdate: (deltaTime) {
    // Calls as long as state machine is in walking state
    // and stateMachine.update called
  },
  onExit: () {
    // Calls when state machine leaves the "walking" state
  },
);
```
Change state:
```dart
stateMachine.state = "walking";
```
### Image Utils
The `ImageUtils` class provides methods to load and manipulate images from different sources.

```dart
// Load an image from raw bytes
final Uint8List imageBytes = getImageBytesFromSomewhere();
final Image? image = await ImageUtils.loadImageFromBytes(imageBytes);
```

You can load images directly from your assets:
```dart
// Load an image from the assets folder
final Image? assetImage = await ImageUtils.loadImageFromAssets('assets/images/player.png');
```

Or load from a file path:
```dart
// Load an image from a file path
final Image? fileImage = await ImageUtils.loadImageFromPath('/path/to/image.png');
```

The class also provides image manipulation utilities:
```dart
// Generate a horizontally flipped version of an image
final Image originalImage = await ImageUtils.loadImageFromAssets('assets/images/character.png');
final Image flippedImage = await ImageUtils.generateFlipped(originalImage);

// You can also pass a custom Paint object to apply effects
final Paint customPaint = Paint()
  ..colorFilter = ColorFilter.mode(Colors.red, BlendMode.srcIn);
final Image tintedFlippedImage = await ImageUtils.generateFlipped(originalImage, customPaint);
```

### Math Utils
The `MathUtils` class provides a variety of mathematical utilities, including random number generation and interpolation functions.

```dart
// Generate a random integer between min (inclusive) and max (exclusive)
final int randomNumber = MathUtils.randInt(1, 10); // Returns 1-9
```

```dart
// Generate a random double between min (inclusive) and max (exclusive)
final double randomDouble = MathUtils.randDouble(0.0, 1.0); // Returns 0.0-0.999...
```

```dart
// Randomly select an item from a list
final List<String> options = ['rock', 'paper', 'scissors'];
final String randomPick = MathUtils.randPick(options);
```

```dart
// Flip a coin (50/50 chance, returns true or false)
final bool coinResult = MathUtils.flipCoin();
```

```dart
// Randomly shuffle a list in place
final List<int> numbers = [1, 2, 3, 4, 5];
MathUtils.shuffle(numbers);
```

```dart
// Seed the random number generator for deterministic results
MathUtils.seedRandom(42); // Using the same seed will generate the same sequence
```

The class also provides interpolation and constraint functions:

```dart
// Linear interpolation between two values
final double interpolated = MathUtils.lerp(0.0, 10.0, 0.5); // Returns 5.0
```

```dart
// Inverse linear interpolation (find where a value sits between two endpoints)
final double percentage = MathUtils.inverseLerp(0.0, 10.0, 5.0); // Returns 0.5
```

```dart
// Remap a value from one range to another
final double remapped = MathUtils.remap(5.0, 0.0, 10.0, 100.0, 200.0); // Maps 5.0 to 150.0
```

```dart
// Constrain a value between min and max
final double constrained = MathUtils.constrain(15.0, 0.0, 10.0); // Returns 10.0
```

```dart
// Find the least common multiple of two integers
final int result = MathUtils.lcm(12, 18); // Returns 36
```

## Contributions
Contributions are welcome! You can submit pull requests, report issues, or suggest improvements in the repository.

You can also use my [ECS library](https://pub.dev/packages/tecs) with this engine.