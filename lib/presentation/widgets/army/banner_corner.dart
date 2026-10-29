import 'dart:ui';

/// The corner of its drill pad where a squad plants its banner.
enum BannerCorner {
  /// Towards the barracks, behind the squad.
  back(Offset(-1, -1)),

  /// Towards the left edge of the screen.
  left(Offset(-1, 1)),

  /// Towards the right edge of the screen.
  right(Offset(1, -1));

  const BannerCorner(this.direction);

  /// Unit step from the pad centre towards the corner, in cells.
  final Offset direction;
}
