abstract final class Helpers {
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

  static String toCamelCase(String input) {
    if (input.isEmpty) return input;

    // snake_case, kebab-case, space -> split by words
    final words = input
        .replaceAll(RegExp(r'[_\-\s]+'), ' ')
        // PascalCase or camelCase bounds
        .replaceAllMapped(
          RegExp(r'(?<=[a-z0-9])([A-Z])'),
          (m) => ' ${m[1]}',
        )
        .split(' ')
        .where((e) => e.isNotEmpty)
        .toList();

    return words.asMap().entries.map((entry) {
      final i = entry.key;
      final word = entry.value.toLowerCase();

      if (i == 0) {
        return word;
      }

      return word[0].toUpperCase() + word.substring(1);
    }).join();
  }
}
