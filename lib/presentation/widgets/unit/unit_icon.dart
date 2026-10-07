import 'package:flutter/material.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/unit_type_extensions.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';

class UnitIcon extends StatelessWidget {
  final UnitType type;
  final double size;
  final bool greyscale;

  const UnitIcon({
    super.key,
    required this.type,
    this.size = 40,
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
