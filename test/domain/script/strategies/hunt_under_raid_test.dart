import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/script/strategies/conquest_strategy.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'event_moves_test_helper.dart';

/// A game at turn 20 where a raid is announced, a weak lair lies in sight
/// of the base and the home army is strong.
({Game game, GridPosition lair}) _underRaid() {
  final Game game = GameFactory.newSinglePlayer(playerName: 'Nemo', mapSeed: 3)
    ..turn = 20;
  final player = game.humanPlayer;
  final GridPosition lair = player
      .revealedCellsOnLevel(1)
      .firstWhere(
        (p) =>
            game.levels[1]!.cellAt(p.x, p.y).content == CellContentType.empty,
      );
  game.levels[1]!.setCell(
    lair.x,
    lair.y,
    game.levels[1]!
        .cellAt(lair.x, lair.y)
        .copyWith(
          content: CellContentType.monsterLair,
          lair: const MonsterLair(
            difficulty: MonsterDifficulty.easy,
            family: MonsterFamily.swarm,
            unitCount: 2,
          ),
        ),
  );
  player.unitsOnLevel(1)[UnitType.harpoonist]!.count = 200;
  player.raidState.announce(
    const MonsterLair(
      difficulty: MonsterDifficulty.easy,
      family: MonsterFamily.swarm,
      unitCount: 2,
    ),
    22,
  );
  return (game: game, lair: lair);
}

bool _cleared(Game game, GridPosition p) =>
    game.levels[1]!.cellAt(p.x, p.y).isCollected;

void main() {
  test('a player leaves the lairs alone while a raid is announced', () {
    final w = _underRaid();
    ConquestStrategy().playTurn(scriptTurnOf(w.game));
    expect(_cleared(w.game, w.lair), isFalse);
  });

  test('a faction clears the lairs it beats even under a raid', () {
    final w = _underRaid();
    ConquestStrategy(huntsUnderRaid: true).playTurn(scriptTurnOf(w.game));
    expect(_cleared(w.game, w.lair), isTrue);
  });
}
