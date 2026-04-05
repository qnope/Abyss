import 'package:flutter/material.dart';
import '../../domain/map_tile.dart';
import '../../domain/tile_content.dart';
import '../widgets/enemy_detail_sheet.dart';
import '../widgets/monster_detail_sheet.dart';
import '../widgets/tile_detail_sheet.dart';

void showMapTileDetail(BuildContext context, MapTile tile) {
  if (!tile.revealed) {
    showTileDetailSheet(context, tile: tile);
    return;
  }

  switch (tile.content) {
    case TileContent.monsterLevel1:
    case TileContent.monsterLevel2:
    case TileContent.monsterLevel3:
      showMonsterDetailSheet(context, tile: tile);
    case TileContent.enemy:
      showEnemyDetailSheet(context, tile: tile);
    case TileContent.empty:
    case TileContent.playerBase:
      showTileDetailSheet(context, tile: tile);
  }
}
