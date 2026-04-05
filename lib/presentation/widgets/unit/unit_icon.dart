import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/unit_type_extensions.dart';
import '../../theme/abyss_colors.dart';

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
