import 'package:tremble/physics/aabb.dart';

class SpatialHash<T> {
  final double cellSize;
  final Map<int, List<T>> _cells = {};
  final List<T> _queryResult = [];
  final Set<T> _querySeen = {};

  SpatialHash({required this.cellSize});

  int _key(int cx, int cy) => (cx * 73856093) ^ (cy * 19349663);

  void _forEachCell(AABB bounds, void Function(int key) fn) {
    final minX = (bounds.left / cellSize).floor();
    final maxX = (bounds.right / cellSize).floor();
    final minY = (bounds.top / cellSize).floor();
    final maxY = (bounds.bottom / cellSize).floor();

    for (var x = minX; x <= maxX; x++) {
      for (var y = minY; y <= maxY; y++) {
        fn(_key(x, y));
      }
    }
  }

  void insert(T obj, AABB bounds) {
    _forEachCell(bounds, (key) {
      _cells.putIfAbsent(key, () => []).add(obj);
    });
  }

  void remove(T obj, AABB bounds) {
    _forEachCell(bounds, (key) {
      final cell = _cells[key];
      if (cell == null) return;
      cell.remove(obj);
      if (cell.isEmpty) _cells.remove(key);
    });
  }

  void update(T obj, AABB oldBounds, AABB newBounds) {
    remove(obj, oldBounds);
    insert(obj, newBounds);
  }

  List<T> query(AABB bounds) {
    _queryResult.clear();
    _querySeen.clear();

    _forEachCell(bounds, (key) {
      final cell = _cells[key];
      if (cell == null) return;
      for (final obj in cell) {
        if (_querySeen.add(obj)) {
          _queryResult.add(obj);
        }
      }
    });

    return _queryResult;
  }

  void clear() {
    _cells.clear();
  }

  int get cellCount => _cells.length;
}
