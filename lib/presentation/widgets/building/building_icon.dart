import 'package:flutter/material.dart';
import '../../../domain/building/building_type.dart';
import '../../extensions/building_type_extensions.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';

class BuildingIcon extends StatelessWidget {
  final BuildingType type;
  final double size;
  final bool greyscale;

  const BuildingIcon({
    super.key,
    required this.type,
    this.size = 24,
    this.greyscale = false,
  });

  @override
  Widget build(BuildContext context) {
    return RasterSvg(
      assetPath: type.iconPath,
      size: size,
      color: greyscale ? AbyssColors.disabled : null,
    );
  }
}
