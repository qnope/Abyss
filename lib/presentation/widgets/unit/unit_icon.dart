import 'package:flutter/material.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/unit_type_extensions.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';

/// Illustration of a unit: in colour, or in greyscale while it is
/// unavailable.
class UnitIcon extends StatelessWidget {
  final UnitType type;
  final double size;

  /// Draws the real illustration in greyscale, e.g. while locked.
  final bool greyscale;

  /// Draws the greyscale illustration slightly translucent, for
  /// unavailable list items.
  final bool faded;

  const UnitIcon({
    super.key,
    required this.type,
    this.size = 40,
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
