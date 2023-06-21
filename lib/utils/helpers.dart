class Helpers {
  static List<T> indexMapToList<T>(Map<int, T> data) {
    final result = <T>[];
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      if (item != null) {
        result.add(item);
      }
    }
    return result;
  }
}
