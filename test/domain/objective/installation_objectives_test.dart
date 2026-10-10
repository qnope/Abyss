import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/map/exploration_order.dart';
import 'package:abyss/domain/map/exploration_resolver.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/objective_helpers.dart';

void main() {
  group('Installation objectives', () {
    test('hqLevel1: QG au niveau 1', () {
      final game = objectiveGame();
      expectProgress(game, ObjectiveId.hqLevel1, 0, 1);
      setBuilding(game.humanPlayer, BuildingType.headquarters, 1);
      expectProgress(game, ObjectiveId.hqLevel1, 1, 1);
    });

    test('algaeFarm: Ferme d\'algues construite', () {
      final game = objectiveGame();
      expectProgress(game, ObjectiveId.algaeFarm, 0, 1);
      setBuilding(game.humanPlayer, BuildingType.algaeFarm, 1);
      expectProgress(game, ObjectiveId.algaeFarm, 1, 1);
    });

    test('mines: Mine de corail et Extracteur, compté sur 2', () {
      final game = objectiveGame();
      expectProgress(game, ObjectiveId.mines, 0, 2);
      setBuilding(game.humanPlayer, BuildingType.oreExtractor, 1);
      expectProgress(game, ObjectiveId.mines, 1, 2);
      setBuilding(game.humanPlayer, BuildingType.coralMine, 3);
      expectProgress(game, ObjectiveId.mines, 2, 2);
    });

    test('solarPanel: Panneau solaire construit', () {
      final game = objectiveGame();
      expectProgress(game, ObjectiveId.solarPanel, 0, 1);
      setBuilding(game.humanPlayer, BuildingType.solarPanel, 1);
      expectProgress(game, ObjectiveId.solarPanel, 1, 1);
    });

    test('hqLevel2: QG au niveau 2, progression par niveau', () {
      final game = objectiveGame();
      setBuilding(game.humanPlayer, BuildingType.headquarters, 1);
      expectProgress(game, ObjectiveId.hqLevel2, 1, 2);
      setBuilding(game.humanPlayer, BuildingType.headquarters, 3);
      expectProgress(game, ObjectiveId.hqLevel2, 2, 2);
    });

    test('barracksAndScouts: Caserne puis 2 Éclaireurs, sur 3', () {
      final game = objectiveGame();
      final player = game.humanPlayer;
      expectProgress(game, ObjectiveId.barracksAndScouts, 0, 3);
      setBuilding(player, BuildingType.barracks, 1);
      expectProgress(game, ObjectiveId.barracksAndScouts, 1, 3);
      setUnits(player, UnitType.scout, 1);
      expectProgress(game, ObjectiveId.barracksAndScouts, 2, 3);
      setUnits(player, UnitType.scout, 1, level: 2);
      expectProgress(game, ObjectiveId.barracksAndScouts, 3, 3);
      setUnits(player, UnitType.scout, 5);
      expectProgress(game, ObjectiveId.barracksAndScouts, 3, 3);
    });

    test('explore: une case révélée hors de la zone de départ', () {
      final game = objectiveGame();
      final player = game.humanPlayer;
      player.addRevealedCell(1, GridPosition(x: 5, y: 5));
      expectProgress(game, ObjectiveId.explore, 0, 1);
      player.addRevealedCell(1, GridPosition(x: 8, y: 5));
      expectProgress(game, ObjectiveId.explore, 1, 1);
    });

    test('explore: done once a real exploration is resolved', () {
      final game = objectiveGame();
      game.humanPlayer.pendingExplorations.add(
        ExplorationOrder(target: GridPosition(x: 8, y: 5), level: 1),
      );
      expectProgress(game, ObjectiveId.explore, 0, 1);
      ExplorationResolver.resolve(game);
      expectProgress(game, ObjectiveId.explore, 1, 1);
    });

    test('laboratoryAndResearch: Laboratoire et une recherche, sur 2', () {
      final game = objectiveGame();
      final player = game.humanPlayer;
      expectProgress(game, ObjectiveId.laboratoryAndResearch, 0, 2);
      setBuilding(player, BuildingType.laboratory, 1);
      expectProgress(game, ObjectiveId.laboratoryAndResearch, 1, 2);
      player.techBranches[TechBranch.explorer]!
        ..unlocked = true
        ..researchLevel = 1;
      expectProgress(game, ObjectiveId.laboratoryAndResearch, 2, 2);
    });

    test('firstRaid: un raid repoussé', () {
      final game = objectiveGame();
      game.humanPlayer.raidState.recordOutcome(victory: false);
      expectProgress(game, ObjectiveId.firstRaid, 0, 1);
      game.humanPlayer.raidState.recordOutcome(victory: true);
      expectProgress(game, ObjectiveId.firstRaid, 1, 1);
    });
  });
}
