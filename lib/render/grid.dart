import 'dart:collection';

class Grid {
  final int cellSize;
  final int width;
  final int height;
  final List<int> _data;

  UnmodifiableListView get data => UnmodifiableListView(_data);
  int get length => width * height;

  Grid({required this.cellSize, required this.width, required this.height, required List<int> data})
      : assert(data.length == width * height, "Grid data and width*height mismatch"),
        _data = data;

  Grid.empty({required this.cellSize, required this.width, required this.height})
      : _data = List.generate(width * height, (_) => -1);

  Grid.from2d({required this.cellSize, required List<List<int>> data})
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
  int tileAt2d(int x, int y) => _data[to1d(x, y)];

  @pragma('vm:prefer-inline')
  int tileAt1d(int idx) => _data[idx];

  @pragma('vm:prefer-inline')
  bool inBounds1d(int idx) => idx >= 0 && idx < length;

  @pragma('vm:prefer-inline')
  bool inBounds2d(int x, int y) => x >= 0 && x < width && y >= 0 && y < height;

  @pragma('vm:prefer-inline')
  bool inBounds2dScreen(double x, double y) =>
      x >= 0 && x < width * cellSize && y >= 0 && y < height * cellSize;

  @pragma('vm:prefer-inline')
  void setTile1d(int value, {required int idx}) => _data[idx] = value;

  @pragma('vm:prefer-inline')
  void setTile2d(int value, {required int x, required int y}) => _data[to1d(x, y)] = value;

  @pragma('vm:prefer-inline')
  void setTile2dScreen(int value, {required double x, required double y}) =>
      _data[to1d(x ~/ cellSize, y ~/ cellSize)] = value;

  String toJson1d() {
    final buffer = StringBuffer();
    buffer.write("[");
    buffer.writeAll(_data, ",");
    buffer.write("]");
    return buffer.toString();
  }

  String toJson2d() {
    final buffer = StringBuffer();
    buffer.write("[");
    for (int j = 0; j < height; j++) {
      if (j > 0) buffer.write(",");
      buffer.write("[");
      buffer.writeAll(_data.sublist(width * j, width * j + width), ",");
      buffer.write("]");
    }
    buffer.write("]");
    return buffer.toString();
  }
}
