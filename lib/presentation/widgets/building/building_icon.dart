import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../domain/building/building_type.dart';
import '../../extensions/building_type_extensions.dart';
import '../../theme/abyss_colors.dart';

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
    return SvgPicture.asset(
      type.iconPath,
      width: size,
      height: size,
      colorFilter: greyscale
          ? const ColorFilter.mode(AbyssColors.disabled, BlendMode.srcIn)
          : null,
    );
  }
}
