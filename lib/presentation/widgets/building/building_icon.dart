import 'package:flutter/material.dart';
import '../../../domain/building/building_type.dart';
import '../../extensions/building_type_extensions.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';

class BuildingIcon extends StatelessWidget {
  final BuildingType type;
  final double size;
  final bool greyscale;

  /// Fades the greyscale icon further, for unavailable list items.
  final bool faded;

  const BuildingIcon({
    super.key,
    required this.type,
    this.size = 24,
    this.greyscale = false,
    this.faded = false,
  });

  Color get _grey =>
      faded ? AbyssColors.dimmed(AbyssColors.disabled) : AbyssColors.disabled;

  @override
  Widget build(BuildContext context) {
    return RasterSvg(
      assetPath: type.iconPath,
      size: size,
      color: greyscale ? _grey : null,
    );
  }
}
