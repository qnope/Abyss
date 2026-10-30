import 'dart:ui';

import '../../theme/abyss_island_colors.dart';

/// The paints the buildings of the base are drawn with, made once and
/// reused: as they are, as a faint cyan ghost while still to build, or
/// greyed while degraded.
class BaseSpritePaints {
  /// Opacity of a ghost, over the alpha its filter keeps: the mockup's
  /// 0.55 looks denser once rasterized, so a little less here.
  static const ghostOpacity = 0.42;

  final _built = Paint()..filterQuality = FilterQuality.medium;
  final _ghost =
      Paint()
        ..filterQuality = FilterQuality.medium
        ..colorFilter = AbyssIslandColors.ghost
        ..color = const Color.fromRGBO(0, 0, 0, ghostOpacity);
  final _degraded =
      Paint()
        ..filterQuality = FilterQuality.medium
        ..colorFilter = AbyssIslandColors.degraded;

  /// The paint of a building at [level], [degraded] or not.
  Paint of({required int level, required bool degraded}) =>
      level <= 0
          ? _ghost
          : degraded
          ? _degraded
          : _built;
}
