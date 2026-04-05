import 'package:flutter/material.dart';
import '../../domain/terrain_type.dart';
import '../theme/abyss_colors.dart';

extension TerrainTypeVisual on TerrainType {
  Color get color => switch (this) {
    TerrainType.plain => AbyssColors.plainBlue,
    TerrainType.reef => AbyssColors.reefPink,
    TerrainType.rock => AbyssColors.rockGray,
    TerrainType.fault => AbyssColors.faultBlack,
  };

  String get displayName => switch (this) {
    TerrainType.plain => 'Plaine sous-marine',
    TerrainType.reef => 'Récif corallien',
    TerrainType.rock => 'Zone rocheuse',
    TerrainType.fault => 'Faille abyssale',
  };

  String get description => switch (this) {
    TerrainType.plain => 'Eaux calmes, rien de notable.',
    TerrainType.reef => 'Des formations coralliennes colorées tapissent le fond.',
    TerrainType.rock => 'Des rochers massifs bloquent la visibilité.',
    TerrainType.fault => 'Une crevasse profonde s\'ouvre dans les ténèbres.',
  };
}
