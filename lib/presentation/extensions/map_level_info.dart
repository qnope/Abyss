/// How the map depths, numbered from 1 at the surface, are named and
/// pictured across the screens.
abstract final class MapLevelInfo {
  /// Every depth, from the surface down to the core.
  static const List<int> levels = [1, 2, 3];

  static const String _thumbnails = 'assets/illustrations/saves';

  static String nameOf(int level) => switch (level) {
    1 => 'Surface',
    2 => 'Profondeurs',
    _ => 'Noyau',
  };

  /// Square thumbnail of a save that reached [level].
  static String saveThumbnailOf(int level) => switch (level) {
    1 => '$_thumbnails/depth_surface.svg',
    2 => '$_thumbnails/depth_deep.svg',
    _ => '$_thumbnails/depth_core.svg',
  };
}
