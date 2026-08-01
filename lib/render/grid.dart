import 'dart:collection';

class Grid<T> {
  final int cellSize;
  final int width;
  final int height;
  final List<T> _data;

  UnmodifiableListView<T> get data => UnmodifiableListView<T>(_data);
  List<T> clone({bool growable = false}) => List.of(_data, growable: growable);

  int get length => width * height;

  Grid({required this.cellSize, required this.width, required this.height, required List<T> data})
      : assert(data.length == width * height, "Grid data and width*height mismatch"),
        _data = data;

  Grid.filled({required this.cellSize, required this.width, required this.height, required T value})
      : _data = List.generate(width * height, (_) => value);

  Grid.from2d({required this.cellSize, required List<List<T>> data})
      : assert(
            data.isNotEmpty && data[0].isNotEmpty, "2d data array must contain at least 1 element"),
        width = data[0].length,
        height = data.length,
        _data = data.expand((e) => e).toList();

  @pragma('vm:prefer-inline')
  int to1d(int x, int y) => y * width + x;

  @pragma('vm:prefer-inline')
  (int, int) to2d(int idx) => (idx % width, idx ~/ width);

  @pragma('vm:prefer-inline')
  T tileAt2d(int x, int y) => _data[to1d(x, y)];

  @pragma('vm:prefer-inline')
  T tileAt1d(int idx) => _data[idx];

  @pragma('vm:prefer-inline')
  bool inBounds1d(int idx) => idx >= 0 && idx < length;

  @pragma('vm:prefer-inline')
  bool inBounds2d(int x, int y) => x >= 0 && x < width && y >= 0 && y < height;

  @pragma('vm:prefer-inline')
  bool inBounds2dScreen(double x, double y) =>
      x >= 0 && x < width * cellSize && y >= 0 && y < height * cellSize;

  @pragma('vm:prefer-inline')
  void setTile1d(T value, {required int idx}) => _data[idx] = value;

  @pragma('vm:prefer-inline')
  void setTile2d(T value, {required int x, required int y}) => _data[to1d(x, y)] = value;

  @pragma('vm:prefer-inline')
  void setTile2dScreen(T value, {required double x, required double y}) => _data[to1d(
        (x / cellSize).floor(),
        (y / cellSize).floor(),
      )] = value;

  @pragma('vm:prefer-inline')
  (int, int) screenToGrid(double x, double y) => ((x / cellSize).floor(), (y / cellSize).floor());

  // Neighbor has controls
  @pragma('vm:prefer-inline')
  bool hasNeighborLeft(int idx) => idx % width > 0;

  @pragma('vm:prefer-inline')
  bool hasNeighborRight(int idx) => idx % width < width - 1;

  @pragma('vm:prefer-inline')
  bool hasNeighborUp(int idx) => idx >= width;

  @pragma('vm:prefer-inline')
  bool hasNeighborDown(int idx) => idx < length - width;

  // One neighbor tile getters
  @pragma('vm:prefer-inline')
  T? leftNeighborTile(int idx) => hasNeighborLeft(idx) ? _data[idx - 1] : null;

  @pragma('vm:prefer-inline')
  T? rightNeighborTile(int idx) => hasNeighborRight(idx) ? _data[idx + 1] : null;

  @pragma('vm:prefer-inline')
  T? upNeighborTile(int idx) => hasNeighborUp(idx) ? _data[idx - width] : null;

  @pragma('vm:prefer-inline')
  T? downNeighborTile(int idx) => hasNeighborDown(idx) ? _data[idx + width] : null;

  @pragma('vm:prefer-inline')
  T? upLeftNeighborTile(int idx) =>
      hasNeighborUp(idx) && hasNeighborLeft(idx) ? _data[idx - width - 1] : null;

  @pragma('vm:prefer-inline')
  T? upRightNeighborTile(int idx) =>
      hasNeighborUp(idx) && hasNeighborRight(idx) ? _data[idx - width + 1] : null;

  @pragma('vm:prefer-inline')
  T? downLeftNeighborTile(int idx) =>
      hasNeighborDown(idx) && hasNeighborLeft(idx) ? _data[idx + width - 1] : null;

  @pragma('vm:prefer-inline')
  T? downRightNeighborTile(int idx) =>
      hasNeighborDown(idx) && hasNeighborRight(idx) ? _data[idx + width + 1] : null;

  /// Calls [visit] for each 4-connected neighbor index without allocating.
  @pragma('vm:prefer-inline')
  void forEachNeighbor4(int idx, void Function(int neighborIdx) visit) {
    if (hasNeighborUp(idx)) visit(idx - width);
    if (hasNeighborDown(idx)) visit(idx + width);
    if (hasNeighborLeft(idx)) visit(idx - 1);
    if (hasNeighborRight(idx)) visit(idx + 1);
  }

  /// Calls [visit] for each 8-connected neighbor index without allocating.
  @pragma('vm:prefer-inline')
  void forEachNeighbor8(int idx, void Function(int neighborIdx) visit) {
    final up = hasNeighborUp(idx);
    final down = hasNeighborDown(idx);
    final left = hasNeighborLeft(idx);
    final right = hasNeighborRight(idx);
    if (up) visit(idx - width);
    if (down) visit(idx + width);
    if (left) visit(idx - 1);
    if (right) visit(idx + 1);
    if (up && left) visit(idx - width - 1);
    if (up && right) visit(idx - width + 1);
    if (down && left) visit(idx + width - 1);
    if (down && right) visit(idx + width + 1);
  }

  /// 4-connected neighbor tile values. Bounds safe. 1 array allocation.
  List<T> neighborTiles4(int idx) {
    final out = <T>[];
    forEachNeighbor4(idx, (n) => out.add(_data[n]));
    return out;
  }

  /// 8-connected neighbor tile values. Bounds safe. 1 array allocation.
  List<T> neighborTiles8(int idx) {
    final out = <T>[];
    forEachNeighbor8(idx, (n) => out.add(_data[n]));
    return out;
  }
}
