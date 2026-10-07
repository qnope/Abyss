import 'package:flutter/material.dart';

import '../../../domain/resource/resource_type.dart';
import '../common/raster_svg.dart';

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
    return RasterSvg(assetPath: _assetPath, size: size);
  }
}
