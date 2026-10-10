import 'package:flutter/material.dart';
import '../../../domain/building/building_type.dart';
import '../../extensions/building_type_extensions.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';

/// Illustration of a building: in colour, or in greyscale while it is
/// unavailable.
class BuildingIcon extends StatelessWidget {
  final BuildingType type;
  final double size;

  /// Draws the real illustration in greyscale, e.g. while unbuilt.
  final bool greyscale;

  /// Draws the greyscale illustration slightly translucent, for
  /// unavailable list items.
  final bool faded;

  const BuildingIcon({
    super.key,
    required this.type,
    this.size = 24,
    this.greyscale = false,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    return RasterSvg(
      assetPath: type.iconPath,
      size: size,
      greyscale: greyscale,
      opacity: faded ? AbyssColors.unavailableOpacity : 1,
    );
  }
}
