import 'package:flutter/material.dart';
import '../../domain/map/terrain_type.dart';
import '../theme/abyss_colors.dart';

extension TerrainTypeExtensions on TerrainType {
  String get label => 'Plaine';

  String get svgPath => 'assets/icons/terrain/plain.svg';

  Color get color => AbyssColors.plainBlue;

  bool get isOpaque => false;
}
