import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/attack_transition_base_action.dart';
import 'package:abyss/domain/action/descend_action.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'transition_test_helper.dart';

const _kFarX = 18;
const _kFarY = 18;
const _kBigMap = 20;

GameMap _buildTwoFailleMap() {
  final cells = List.generate(
    _kBigMap * _kBigMap,
    (_) => MapCell(terrain: TerrainType.plain),
  );

  void placeFaille(int x, int y, String name) {
    cells[y * _kBigMap + x] = MapCell(
      terrain: TerrainType.plain,
      content: CellContentType.transitionBase,
      transitionBase: TransitionBase(
        type: TransitionBaseType.faille,
        name: name,
      ),
    );
  }

  placeFaille(kFailleX, kFailleY, 'Faille Alpha');
  placeFaille(_kFarX, _kFarY, 'Faille Beta');

  return GameMap(
    width: _kBigMap,
    height: _kBigMap,
    cells: cells,
    seed: 42,
  );
}

({Game game, Player player}) _captureAndDescend(GameMap map) {
  final s = buildTransitionScenario();
  final game = Game(
    humanPlayerId: s.player.id,
    players: {s.player.id: s.player},
    levels: {1: map},
  );

  final executor = ActionExecutor();
  executor.execute(
    AttackTransitionBaseAction(
      targetX: kFailleX,
      targetY: kFailleY,
      level: 1,
      selectedUnits: {
        UnitType.abyssAdmiral: 1,
        UnitType.domeBreaker: 30,
      },
      random: Random(42),
    ),
    game,
    s.player,
  );

  final result = executor.execute(
    DescendAction(
      transitionX: kFailleX,
      transitionY: kFailleY,
      fromLevel: 1,
      selectedUnits: {UnitType.scout: 5},
    ),
    game,
    s.player,
  );
  expect(result.isSuccess, isTrue);

  return (game: game, player: s.player);
}

void main() {
  group('Passage markers after descent', () {
    test('passage cells appear at faille positions on level 2', () {
      final s = _captureAndDescend(_buildTwoFailleMap());
      final level2 = s.game.levels[2]!;

      final near = level2.cellAt(kFailleX, kFailleY);
      expect(near.content, CellContentType.passage);
      expect(near.passageName, 'Faille Alpha');

      final far = level2.cellAt(_kFarX, _kFarY);
      expect(far.content, CellContentType.passage);
      expect(far.passageName, 'Faille Beta');
    });

    test('passage cells have no lair or transition base', () {
      final s = _captureAndDescend(_buildTwoFailleMap());
      final level2 = s.game.levels[2]!;

      for (final (x, y) in [(kFailleX, kFailleY), (_kFarX, _kFarY)]) {
        final cell = level2.cellAt(x, y);
        expect(cell.lair, isNull, reason: 'passage ($x,$y) lair');
        expect(
          cell.transitionBase,
          isNull,
          reason: 'passage ($x,$y) transitionBase',
        );
      }
    });

    test('far passage cell is not revealed on descent', () {
      final s = _captureAndDescend(_buildTwoFailleMap());
      final revealed = s.player.revealedCellsPerLevel[2]!;

      final nearPos = GridPosition(x: kFailleX, y: kFailleY);
      expect(revealed.contains(nearPos), isTrue);

      final farPos = GridPosition(x: _kFarX, y: _kFarY);
      expect(revealed.contains(farPos), isFalse);
    });
  });
}
