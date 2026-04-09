import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/fight/fight_turn_summary.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/exploration_order.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:hive/hive.dart';

void registerFightPersistenceAdapters() {
  if (Hive.isAdapterRegistered(0)) return;
  Hive.registerAdapter(BuildingTypeAdapter());
  Hive.registerAdapter(BuildingAdapter());
  Hive.registerAdapter(ResourceTypeAdapter());
  Hive.registerAdapter(ResourceAdapter());
  Hive.registerAdapter(TechBranchAdapter());
  Hive.registerAdapter(TechBranchStateAdapter());
  Hive.registerAdapter(PlayerAdapter());
  Hive.registerAdapter(UnitTypeAdapter());
  Hive.registerAdapter(UnitAdapter());
  Hive.registerAdapter(TerrainTypeAdapter());
  Hive.registerAdapter(CellContentTypeAdapter());
  Hive.registerAdapter(MonsterDifficultyAdapter());
  Hive.registerAdapter(MonsterLairAdapter());
  Hive.registerAdapter(MapCellAdapter());
  Hive.registerAdapter(GameMapAdapter());
  Hive.registerAdapter(GridPositionAdapter());
  Hive.registerAdapter(ExplorationOrderAdapter());
  Hive.registerAdapter(GameAdapter());
  Hive.registerAdapter(HistoryEntryCategoryAdapter());
  Hive.registerAdapter(BuildingEntryAdapter());
  Hive.registerAdapter(ResearchEntryAdapter());
  Hive.registerAdapter(RecruitEntryAdapter());
  Hive.registerAdapter(ExploreEntryAdapter());
  Hive.registerAdapter(CollectEntryAdapter());
  Hive.registerAdapter(CombatEntryAdapter());
  Hive.registerAdapter(TurnEndEntryAdapter());
  Hive.registerAdapter(CombatSideAdapter());
  Hive.registerAdapter(CombatantAdapter());
  Hive.registerAdapter(FightTurnSummaryAdapter());
  Hive.registerAdapter(FightResultAdapter());
  Hive.registerAdapter(TurnResourceChangeAdapter());
}

GameMap buildFightPersistenceMap() {
  final cells = <MapCell>[];
  for (var y = 0; y < 5; y++) {
    for (var x = 0; x < 5; x++) {
      if (x == 1 && y == 1) {
        cells.add(MapCell(
          terrain: TerrainType.plain,
          content: CellContentType.monsterLair,
          lair: const MonsterLair(
            difficulty: MonsterDifficulty.easy,
            unitCount: 2,
          ),
        ));
      } else {
        cells.add(MapCell(terrain: TerrainType.plain));
      }
    }
  }
  return GameMap(width: 5, height: 5, cells: cells, seed: 99);
}

Game buildFightPersistenceGame() {
  final Player player = Player(
    id: 'persist-uuid',
    name: 'Persist',
    baseX: 2,
    baseY: 2,
  );
  player.units[UnitType.harpoonist]!.count = 15;
  player.addRevealedCell(GridPosition(x: 1, y: 1));
  return Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    gameMap: buildFightPersistenceMap(),
  );
}
