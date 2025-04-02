# Tremble
A really simple "game engine" written in Flutter. It doesn’t enforce a complex structure; instead, it follows a straightforward setup/draw function pattern used by frameworks like p5.js, Processing, Raylib, LÖVE, Pico-8, and others.

 ## Usage
 Use the `GameArea` widget with a `ScreenController` and you are good to go.
 
 This example shows how you can restrict a specific size. By using `FittedBox` and `SizedBox` together, you can get the letterbox effect If the window is not in your desired aspect ratio.
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
It's a way to get user input, do asset loading and render something to screen. In it's simplest form, it looks like this.
```dart
class DemoController extends ScreenController {
  @override
  void setup(BuildContext context, double width, double height) {
    // Runs once at the start (just before the first frame drawn to the screen)
    // Gives you access to the buildcontext, screen width and height
  }

  @override
  void update(double deltaTime) {
    // Runs 60 times per second
    // Gives you access to deltaTime for frame independent calculations
    // This is where you update your objects
  }

  @override
  void draw(Canvas canvas, Size size) {
    // Runs 60 times per second
    // Gives you access to flutter Canvas and screen size
    // This is where you render stuff to the screen
  }

  @override
  void dispose() {
    // Runs at the end (when the widget is removed from the widget tree)
    // You can cleanup and dispose your assets here
  }
}
```

> Everything below are optional override functions and they go inside the `ScreenController`.
### Keyboard Input
These keyboard input functions triggers once every key input.
```dart
@override
void keyDown(LogicalKeyboardKey key) {
	if (key == LogicalKeyboardKey.arrowLeft) {
	  // Left arrow key is just pressed
	}
}

@override
void keyUp(LogicalKeyboardKey key) {
	if (key == LogicalKeyboardKey.space) {
	  // Space key is just released
	}
}
```
If you want to check for a continuous press(holding down a key), you can just use a `Set` and check in the update function like this:
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
// Triggers many times, when you move the mouse over the GameArea
// Provides you with the mouse x and y positions
// It also gives you a pointer id which is good for multi touch detection
}

@override
void mousePressed(int pointerID, int button, double mouseX, double mouseY) {
// Tiggers when a mouse button is pressed
// Provides you a button which is to detect which mouse button is pressed
// Provides you with the mouse x and y positions at the moment of press
}

@override
void mouseReleased(int pointerID) {
// Tiggers when a mouse button is released
// You can match the pointer id of this with a pointer id of a mouse press
// Since every press is followed by an eventual release, pointerID's will match
}

@override
void mouseScroll(Offset scrollOffset) {
// Triggers when the mouse wheel is scrolled.
// Provides you with scroll offset so you can determine the speed and direction of the scroll
}
```
### Resize
If you use the `FittedBox` method this function will never be called. Because the internal screen size will always be the same and the `FittedBox` widget will try to fit the `GameArea` into the screen. But If you want a dynamic screen size, every time someone resizes the window, this function will be called.
```dart
@override
void resize(double width, double height) {
}
```

### Preload
Since loading the assets might take time, you can use the `async` preload function.
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
	done(); // You must call done() at the end.
}
```
You can call the progress function with increasing levels and use this progression to build some kind of loading screen. 
You might be wondering about how to use this progression level.
```dart
GameArea(
	controller: DemoController(),
	loadingBuilder: (context, progress) {
		return Center(child: LinearProgressIndicator(value: progress));
	},
),
```
If you include a `preload` override in your controller, until you call `done();`, whatever widget you put inside the `loadingBuilder` will be rendered instead of the game. `setup`, `update` and `draw` functions will be on hold and wait for the loading.
### SpriteBatch, Sprite, Animation
Using the `Canvas` object that is provided in the `draw` function, you can draw shapes, images, texts, etc. But you will eventually need to do animations. Tremble has `SpriteBatch`, `Sprite` and `Animation` helper classes for you.
#### SpriteBatch
Every image draw call takes time. If you want to shorten that time, you need to knock on the graphics card door as rare as possible. By using `SpriteBatch` we can group many sprite drawings together.
```dart
late final SpriteBatch spriteBatch;

@override
Future<void> preload(progress, done) async {
	spriteBatch = await SpriteBatch.fromOldGdxPacker("assets/batches/sprites.atlas", flippable: true);
	progress(1.0);
	done();
}
```
I am mainly using the [gdx-texture-packer](https://github.com/crashinvaders/gdx-texture-packer-gui) for my texture packing needs. Recently they updated the output format. That's why there are two initialization functions `SpriteBatch.fromOldGdxPacker` and `SpriteBatch.fromGdxPacker`. There is also a `SpriteBatch.custom` If you want to implement your own. In the future there will be more implementations for different kinds of programs. Your contributions are welcome as well. Let's see how we can use the `SpriteBatch`.
- By calling `spriteBatch.getTexture("texture_name")` we will get a `Rect` object. You can think of this `Rect` object as a some kind of window into the big atlas image. Small portion of the big image. 
- By calling `spriteBatch.getAnimation("hero-idle", speed: 10)` we will get `AnimationData`. `AnimationData` is basically a list of `Rect` objects with extra animation info like `speed` and `loop`.
- We will be using `getTexture` with `Sprite` objects and `getAnimation` with `Animation` objects.
#### Using with Sprite
Sprites are single images with no animations.
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
Animations are also `Sprite` objects under the hood. So you can also use `Sprite` object properties with extra animation goodnes. 
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
Unlike `Sprite` objects, you need to update the `Animation` objects so that they will play.
```dart
hero.update(deltaTime);
```
Since the `Animation` objects takes list of animations, you can switch between them.
```dart
// When not moving
hero.setAnimation("hero-idle");
// When moving
hero.setAnimation("hero-run", fromFrame: 0);
// Also If you are moving right and the run animation is also right
hero.flip = false;
// If you are moving to the left
hero.flip = true;
```

#### How do we draw Sprite and Animation objects ?
```dart
spriteBatch.draw(canvas, [hero, table]);
```
Hero and table will be rendered at their .x .y positions, with their properties. `SpriteBatch` draw function takes a canvas to draw onto, and a list of `Sprite` objects. Since the table is a `Sprite` and the hero is also a `Sprite` (despite being an `Animation`), it works.

## Helpers
### Signal
Will be updated, checkout from the source for now :)
### Wait Events
Will be updated, checkout from the source for now :)
### State Machine
Will be updated, checkout from the source for now :)
### Image Utils
Will be updated, checkout from the source for now :)
### Math Utils
Will be updated, checkout from the source for now :)

---
> Any contributions are welcome. You can also use my [ECS](https://pub.dev/packages/tecs) library with this engine.