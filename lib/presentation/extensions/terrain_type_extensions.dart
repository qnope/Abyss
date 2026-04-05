import 'package:flutter/material.dart';
import '../../domain/map/terrain_type.dart';
import '../theme/abyss_colors.dart';

extension TerrainTypeExtensions on TerrainType {
  String get label => switch (this) {
    TerrainType.reef => 'Récif',
    TerrainType.plain => 'Plaine',
    TerrainType.rock => 'Roche',
    TerrainType.fault => 'Faille',
  };

  String get svgPath => switch (this) {
    TerrainType.reef => 'assets/icons/terrain/reef.svg',
    TerrainType.plain => 'assets/icons/terrain/plain.svg',
    TerrainType.rock => 'assets/icons/terrain/rock.svg',
    TerrainType.fault => 'assets/icons/terrain/fault.svg',
  };

  Color get color => switch (this) {
    TerrainType.reef => AbyssColors.reefPink,
    TerrainType.plain => AbyssColors.plainBlue,
    TerrainType.rock => AbyssColors.rockGray,
    TerrainType.fault => AbyssColors.faultBlack,
  };

  bool get isOpaque => switch (this) {
    TerrainType.reef => false,
    TerrainType.plain => false,
    TerrainType.rock => true,
    TerrainType.fault => true,
  };
}
