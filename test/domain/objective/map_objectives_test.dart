import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/map_tab_harness.dart';
import '../../helpers/objective_helpers.dart';

void main() {
  void place(Game game, int level, MapCell cell) {
    game.levels = {...game.levels, level: game.levels[level] ?? plainMap()};
    game.levels[level]!.setCell(7, 7, cell);
  }

  MapCell lair({String? by}) => MapCell(
    terrain: TerrainType.plain,
    content: CellContentType.monsterLair,
    lair: const MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 3),
    collectedBy: by,
  );

  MapCell base(TransitionBaseType type, {String? by}) => MapCell(
    terrain: TerrainType.plain,
    content: CellContentType.transitionBase,
    transitionBase: TransitionBase(type: type, name: 'X', capturedBy: by),
  );

  MapCell kernel({String? by}) => MapCell(
    terrain: TerrainType.plain,
    content: CellContentType.volcanicKernel,
    collectedBy: by,
  );

  group('Map objectives', () {
    test('takeLair: un repaire vaincu par le joueur', () {
      final game = objectiveGame();
      place(game, 1, lair());
      expectProgress(game, ObjectiveId.takeLair, 0, 1);
      place(game, 1, lair(by: 'someone else'));
      expectProgress(game, ObjectiveId.takeLair, 0, 1);
      place(game, 2, lair(by: game.humanPlayerId));
      expectProgress(game, ObjectiveId.takeLair, 1, 1);
    });

    test('takeFaille: la Faille capturée par le joueur', () {
      final game = objectiveGame();
      place(game, 1, base(TransitionBaseType.faille));
      expectProgress(game, ObjectiveId.takeFaille, 0, 1);
      place(game, 1, base(TransitionBaseType.faille, by: game.humanPlayerId));
      expectProgress(game, ObjectiveId.takeFaille, 1, 1);
    });

    test('takeCheminee: la Cheminée capturée, pas la Faille', () {
      final game = objectiveGame();
      place(game, 1, base(TransitionBaseType.faille, by: game.humanPlayerId));
      expectProgress(game, ObjectiveId.takeCheminee, 0, 1);
      place(game, 2, base(TransitionBaseType.cheminee, by: game.humanPlayerId));
      expectProgress(game, ObjectiveId.takeCheminee, 1, 1);
    });

    test('takeKernel: le Noyau volcanique pris par le joueur', () {
      final game = objectiveGame();
      place(game, 3, kernel());
      expectProgress(game, ObjectiveId.takeKernel, 0, 1);
      place(game, 3, kernel(by: game.humanPlayerId));
      expectProgress(game, ObjectiveId.takeKernel, 1, 1);
    });

    test('descendLevel2: zone d\'arrivée révélée au niveau 2', () {
      final game = objectiveGame();
      game.levels = {...game.levels, 2: plainMap()};
      expectProgress(game, ObjectiveId.descendLevel2, 0, 1);
      game.humanPlayer.addRevealedCell(2, GridPosition(x: 1, y: 1));
      expectProgress(game, ObjectiveId.descendLevel2, 1, 1);
    });

    test('descendLevel3: des unités du joueur au niveau 3', () {
      final game = objectiveGame();
      game.levels = {...game.levels, 3: plainMap()};
      setUnits(game.humanPlayer, UnitType.scout, 0, level: 3);
      expectProgress(game, ObjectiveId.descendLevel3, 0, 1);
      setUnits(game.humanPlayer, UnitType.guardian, 2, level: 3);
      expectProgress(game, ObjectiveId.descendLevel3, 1, 1);
    });

    test('descendLevel3: rien sans carte du niveau 3', () {
      final game = objectiveGame();
      setUnits(game.humanPlayer, UnitType.guardian, 2, level: 3);
      expectProgress(game, ObjectiveId.descendLevel3, 0, 1);
    });
  });
}
