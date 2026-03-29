import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ResourceType { algae, coral, ore, energy, pearl }

class ResourceIcon extends StatelessWidget {
  final ResourceType type;
  final double size;

  const ResourceIcon({
    super.key,
    required this.type,
    this.size = 24,
  });

  String get _assetPath =>
    'assets/icons/resources/${type.name}.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _assetPath,
      width: size,
      height: size,
    );
  }
}
