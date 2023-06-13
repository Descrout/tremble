class Sprite {
  Sprite({
    required this.texture,
    required this.x,
    required this.y,
    this.index,
    this.originX = 0.5,
    this.originY = 0.5,
    this.opacity = 1.0,
    this.scale = 1.0,
    this.rotation = 0,
  });

  String texture;
  int? index;

  double x;
  double y;

  double originX;
  double originY;

  double opacity;
  double rotation;
  double scale;
}
