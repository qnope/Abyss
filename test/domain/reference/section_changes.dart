import 'package:abyss/domain/action/upgrade_building_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/exploration_order.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/reinforcement_order.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import 'later_section_changes.dart';

/// One change of state.
typedef Change = void Function(Game game);

/// The first faction of [g].
Player rivalOf(Game g) => g.players[g.factions.first.id]!;

void _take(Game g, int level) {
  final map = g.levels[level]!;
  map.setCell(1, 0, map.cellAt(1, 0).copyWith(collectedBy: g.humanPlayerId));
}

/// For each section of a snapshot, changes of state it alone must show,
/// on a game against two factions whose three levels exist.
final Map<String, List<Change>> sectionChanges = <String, List<Change>>{
  'game': [
    (g) => g.turn++,
    (g) => g.status = GameStatus.freePlay,
    (g) => g.savedDifficulty = Difficulty.hard,
    (g) => g.savedFactions = [FactionPersonality.magmaSmiths],
  ],
  'journal': [
    (g) => g.replay!.exact = false,
    (g) => g.replay!.endTurnSeeds[1] = 5,
    (g) => g.replay!.record(
      1,
      UpgradeBuildingAction(buildingType: BuildingType.algaeFarm),
    ),
    (g) => g.replay = null,
  ],
  'leviathan': [
    (g) => g.leviathanReturn!.over = true,
    (g) => g.leviathanReturn!.schedule(
      postName: 'faille-1',
      level: 1,
      at: GridPosition(x: 2, y: 3),
      capturedOn: 4,
    ),
    (g) => g.leviathanReturn = null,
  ],
  'map1': [(g) => _take(g, 1)],
  'map2': [(g) => _take(g, 2)],
  'map3': [(g) => _take(g, 3), (g) => g.levels.remove(3)],
  'players': [
    (g) => g.humanPlayer.baseX++,
    (g) => rivalOf(g).baseY++,
    (g) => rivalOf(g).savedFallen = true,
  ],
  'resources': [
    (g) => g.humanPlayer.resources[ResourceType.pearl]!.amount++,
    (g) => rivalOf(g).resources[ResourceType.algae]!.amount--,
  ],
  'buildings': [
    (g) => g.humanPlayer.buildings[BuildingType.headquarters]!.level++,
  ],
  'worksite': [
    (g) => g.humanPlayer.worksite.upgrades++,
    (g) => rivalOf(g).worksite.research++,
  ],
  'tech': [
    (g) => g.humanPlayer.techBranches[TechBranch.military]!.unlocked = true,
    (g) => g.humanPlayer.techBranches[TechBranch.explorer]!.researchLevel++,
    (g) => g.humanPlayer.techBranches[TechBranch.resources]!.choose(
      2,
      TechOption.b,
    ),
  ],
  'units': [
    (g) => g.humanPlayer.unitsOnLevel(1)[UnitType.scout]!.count++,
    (g) => g.humanPlayer.recruitedUnitTypes.add(UnitType.scout),
    (g) => g.humanPlayer.unitsPerLevel[2] = {},
    // The order of a map is state: the same units, the scout moved last.
    (g) {
      final units = g.humanPlayer.unitsOnLevel(1);
      units[UnitType.scout] = units.remove(UnitType.scout)!;
    },
  ],
  'orders': [
    (g) => g.humanPlayer.pendingExplorations.add(
      ExplorationOrder(target: GridPosition(x: 1, y: 1)),
    ),
    (g) => g.humanPlayer.pendingReinforcements.add(
      ReinforcementOrder(
        fromLevel: 1,
        toLevel: 2,
        units: {UnitType.scout: 1},
        departTurn: 3,
        arrivalPoint: GridPosition(x: 4, y: 5),
      ),
    ),
  ],
  'fog': [
    (g) => g.humanPlayer.revealedCellsOnLevel(1).removeLast(),
    (g) => g.humanPlayer.addRevealedCell(2, GridPosition(x: 0, y: 0)),
    (g) {
      final cells = g.humanPlayer.revealedCellsOnLevel(1);
      cells.add(cells.removeAt(0));
    },
  ],
  ...laterSectionChanges,
};
