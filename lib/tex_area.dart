import 'dart:ui';

class TexArea {
  final Rect rect;
  final int pageIndex;

  const TexArea({required this.rect, this.pageIndex = 0});

  double get left => rect.left;
  double get top => rect.top;
  double get width => rect.width;
  double get height => rect.height;
  double get right => rect.right;
  double get bottom => rect.bottom;

  TexArea copy() => TexArea(
      rect: Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height), pageIndex: pageIndex);

  @override
  String toString() => 'TexArea(rect: $rect, pageIndex: $pageIndex)';
}
