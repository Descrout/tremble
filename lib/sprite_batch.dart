import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:tremble/tremble.dart';

class SpriteBatch {
  SpriteBatch._({
    required List<Image> pages,
    required Map<String, TexArea> textures,
    required Map<String, List<TexArea>> frames,
  })  : _pages = pages,
        _textures = textures,
        _frames = frames;

  final List<Image> _pages;
  final Map<String, TexArea> _textures;
  final Map<String, List<TexArea>> _frames;

  Image get image => _pages[0];
  List<Image> get pages => _pages;
  Map<String, TexArea> get textures => _textures;
  Map<String, List<TexArea>> get frames => _frames;

  static final Paint _emptyPaint = Paint()
    ..filterQuality = FilterQuality.none
    ..isAntiAlias = false;

  static Future<SpriteBatch> custom({
    required List<Image> pages,
    required Map<String, TexArea> textures,
    required Map<String, List<TexArea>> frames,
    bool flippable = false,
    bool maskable = false,
    bool disposeOriginal = false,
  }) async {
    final newPages = <Image>[];
    for (final page in pages) {
      newPages.add(await transformSheetImage(
        page,
        flippable: flippable,
        maskable: maskable,
        disposeOriginal: disposeOriginal,
      ));
    }

    return SpriteBatch._(
      pages: newPages,
      textures: textures,
      frames: frames,
    );
  }

  static Future<Image> transformSheetImage(
    Image image, {
    required bool flippable,
    required bool maskable,
    bool disposeOriginal = false,
  }) async {
    Image transformed = image;

    if (maskable) {
      final newImage = await ImageUtils.generateMasked(transformed);
      if (transformed != image || disposeOriginal) {
        transformed.dispose();
      }
      transformed = newImage;
    }

    if (flippable) {
      final newImage = await ImageUtils.generateFlipped(transformed);
      if (transformed != image || disposeOriginal) {
        transformed.dispose();
      }
      transformed = newImage;
    }

    return transformed;
  }

  static bool _isImageFile(String line) {
    final lower = line.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp');
  }

  static Future<SpriteBatch> fromGdxPacker(String path,
      {bool flippable = false, bool maskable = false}) async {
    TexArea getTexArea(String boundsStr, int pageIndex) {
      final split = boundsStr.split(',');
      return TexArea(
        rect: Rect.fromLTWH(
          double.parse(split[0]),
          double.parse(split[1]),
          double.parse(split[2]),
          double.parse(split[3]),
        ),
        pageIndex: pageIndex,
      );
    }

    final atlas = await rootBundle.loadString(path);

    final pages = <Image>[];
    final textures = <String, TexArea>{};
    final framesMap = <String, SplayTreeMap<int, TexArea>>{};

    final lines = atlas.split(RegExp(r'\r?\n')).map((e) => e.trim()).toList();

    int i = 0;
    while (i < lines.length) {
      final line = lines[i];

      if (_isImageFile(line)) {
        final pageIndex = pages.length;

        final pathSplit = path.split("/");
        pathSplit.removeLast();
        pathSplit.add(line);
        final image = await ImageUtils.loadImageFromAssets(pathSplit.join("/"));
        assert(image != null, "Batch image could not be loaded '${pathSplit.join("/")}' !");
        final newImage = await transformSheetImage(
          image!,
          flippable: flippable,
          maskable: maskable,
          disposeOriginal: true,
        );
        pages.add(newImage);

        i++;

        while (i < lines.length && lines[i].contains(":")) {
          i++;
        }

        while (i < lines.length && !_isImageFile(lines[i]) && lines[i] != "") {
          final name = lines[i];
          i++;

          if (name.contains(":")) continue;

          final tempValues = <String, String>{};
          while (i < lines.length && lines[i].contains(":")) {
            final splitted = lines[i].split(":");
            tempValues[splitted[0]] = splitted[1];
            i++;
          }

          if (tempValues.containsKey("index")) {
            if (!framesMap.containsKey(name)) framesMap[name] = SplayTreeMap<int, TexArea>();
            final idx = int.parse(tempValues["index"]!);
            framesMap[name]![idx] = getTexArea(tempValues["bounds"]!, pageIndex);
          } else {
            textures[name] = getTexArea(tempValues["bounds"]!, pageIndex);
          }
        }
      } else {
        i++;
      }
    }

    assert(pages.isNotEmpty, "No atlas pages found!");

    return SpriteBatch._(
      pages: pages,
      textures: textures,
      frames: framesMap.map((key, value) => MapEntry(key, value.values.toList())),
    );
  }

  static Future<SpriteBatch> fromOldGdxPacker(String path,
      {bool flippable = false, bool maskable = false}) async {
    (int, int) getTupple(String data) {
      final split = data.split(',');
      return (int.parse(split[0]), int.parse(split[1]));
    }

    ({String name, TexArea texArea, int? index}) getInfo(
        List<String> lines, int idx, int pageIndex) {
      late Size size;
      late Offset offset;
      int? index;

      for (int i = 1; i < 7; i++) {
        final [tag, data] = lines[idx + i].trim().split(':');
        switch (tag) {
          case "xy":
            final pos = getTupple(data);
            offset = Offset(pos.$1.toDouble(), pos.$2.toDouble());
            break;
          case "size":
            final wh = getTupple(data);
            size = Size(wh.$1.toDouble(), wh.$2.toDouble());
            break;
          case "index":
            if (data != "-1") {
              index = int.parse(data);
            }
            break;
        }
      }

      return (
        name: lines[idx].trim(),
        texArea: TexArea(rect: offset & size, pageIndex: pageIndex),
        index: index,
      );
    }

    final atlas = await rootBundle.loadString(path);

    final textures = <String, TexArea>{};
    final framesMap = <String, SplayTreeMap<int, TexArea>>{};
    final lines = atlas.split(RegExp(r'\r?\n')).map((e) => e.trim()).toList();

    for (int i = 6; i < lines.length - 1; i += 7) {
      final info = getInfo(lines, i, 0);
      if (info.index != null) {
        if (!framesMap.containsKey(info.name)) framesMap[info.name] = SplayTreeMap<int, TexArea>();
        framesMap[info.name]![info.index!] = info.texArea;
      } else {
        textures[info.name] = info.texArea;
      }
    }

    final pathSplit = path.split("/");
    pathSplit.removeLast();
    pathSplit.add(lines[1]);

    final image = await ImageUtils.loadImageFromAssets(pathSplit.join("/"));
    assert(image != null, "Batch image could not be loaded !");
    final newImage = await transformSheetImage(
      image!,
      flippable: flippable,
      maskable: maskable,
      disposeOriginal: true,
    );

    return SpriteBatch._(
      pages: [newImage],
      textures: textures,
      frames: framesMap.map((key, value) => MapEntry(key, value.values.toList())),
    );
  }

  TexArea getTexture(String key) {
    return _textures[key]!;
  }

  Rect getRect(String key) {
    return _textures[key]!.rect;
  }

  Rect _spriteRect(Sprite sprite) {
    final rect = sprite.texture.rect;
    if (!sprite.flip && !sprite.mask) return rect;

    final page = _pages[sprite.texture.pageIndex];
    double x = rect.left;
    double y = rect.top;

    if (sprite.flip) x = page.width - rect.right;
    if (sprite.mask) y += page.height * 0.5;

    return Rect.fromLTWH(
      x,
      y,
      rect.width,
      rect.height,
    );
  }

  AnimationData getAnimation(
    String name, {
    required double speed,
    AnimMode mode = AnimMode.playStop,
    bool reverse = false,
  }) =>
      AnimationData(
        name: name,
        frames: _frames[name] ?? [_textures[name]!],
        speed: speed,
        mode: mode,
        reverse: reverse,
      );

  // Reusable buffers
  Float32List _rects = Float32List(0);
  Float32List _transforms = Float32List(0);
  Int32List _colors = Int32List(0);

  void _ensureCapacity(int count) {
    final needed = count * 4;
    if (_rects.length < needed) {
      final newSize = math.max(needed, (_rects.length * 1.5).round());
      _rects = Float32List(newSize);
      _transforms = Float32List(newSize);
      _colors = Int32List(newSize ~/ 4);
    }
  }

  void _drawBatch(
      Canvas canvas, int start, int count, int pageIndex, Paint? paint, BlendMode blendMode) {
    if (count == 0) return;
    canvas.drawRawAtlas(
      _pages[pageIndex],
      Float32List.sublistView(_transforms, start * 4, (start + count) * 4),
      Float32List.sublistView(_rects, start * 4, (start + count) * 4),
      Int32List.sublistView(_colors, start, start + count),
      blendMode,
      null,
      paint ?? _emptyPaint,
    );
  }

  void draw(Canvas canvas, List<Sprite> sprites,
      [Paint? paint, BlendMode blendMode = BlendMode.modulate]) {
    final count = sprites.length;
    if (count == 0) return;
    _ensureCapacity(count);

    int bufIdx = 0;
    int batchStart = 0;
    int currentPage = sprites[0].texture.pageIndex;

    for (int j = 0; j < count; j++) {
      final sprite = sprites[j];

      if (j > 0 && sprite.texture.pageIndex != currentPage) {
        _drawBatch(canvas, batchStart, bufIdx - batchStart, currentPage, paint, blendMode);
        currentPage = sprite.texture.pageIndex;
        batchStart = bufIdx;
      }

      final rect = _spriteRect(sprite);

      final ri = bufIdx * 4;
      _rects[ri + 0] = rect.left;
      _rects[ri + 1] = rect.top;
      _rects[ri + 2] = rect.right;
      _rects[ri + 3] = rect.bottom;

      double scos = sprite.scale;
      double ssin = 0;
      if (sprite.rotation != 0) {
        scos = math.cos(sprite.rotation) * sprite.scale;
        ssin = math.sin(sprite.rotation) * sprite.scale;
      }

      final anchorX = rect.width * sprite.originX;
      final anchorY = rect.height * sprite.originY;

      final tx = sprite.position.x + -scos * anchorX + ssin * anchorY;
      final ty = sprite.position.y + -ssin * anchorX - scos * anchorY;

      final ti = bufIdx * 4;
      _transforms[ti + 0] = scos;
      _transforms[ti + 1] = ssin;
      _transforms[ti + 2] = tx;
      _transforms[ti + 3] = ty;

      _colors[bufIdx] = sprite.tint.withAlpha(sprite.opacity).toARGB32();

      bufIdx++;
    }

    _drawBatch(canvas, batchStart, bufIdx - batchStart, currentPage, paint, blendMode);
  }

  void dispose() {
    for (final page in _pages) {
      page.dispose();
    }
  }
}
