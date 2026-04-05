import 'package:flutter/material.dart';
import '../../domain/tile_content.dart';
import '../theme/abyss_colors.dart';

extension TileContentVisual on TileContent {
  IconData? get icon => switch (this) {
    TileContent.empty => null,
    TileContent.playerBase => Icons.home,
    TileContent.monsterLevel1 => Icons.pest_control,
    TileContent.monsterLevel2 => Icons.pest_control,
    TileContent.monsterLevel3 => Icons.pest_control,
    TileContent.enemy => Icons.shield,
  };

  Color get iconColor => switch (this) {
    TileContent.empty => AbyssColors.disabled,
    TileContent.playerBase => AbyssColors.biolumCyan,
    TileContent.monsterLevel1 => AbyssColors.algaeGreen,
    TileContent.monsterLevel2 => AbyssColors.energyYellow,
    TileContent.monsterLevel3 => AbyssColors.error,
    TileContent.enemy => AbyssColors.biolumPurple,
  };

  double get iconSize => switch (this) {
    TileContent.empty => 0,
    TileContent.playerBase => 22,
    TileContent.monsterLevel1 => 14,
    TileContent.monsterLevel2 => 18,
    TileContent.monsterLevel3 => 22,
    TileContent.enemy => 22,
  };
}
