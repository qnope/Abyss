import 'dart:math';

import 'package:abyss/domain/action/upgrade_building_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/script/script_log_entry.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/economy_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/two_player_game.dart';

Map<BuildingType, int> _levels(Player player) =>
    player.buildings.map((t, b) => MapEntry(t, b.level));

Map<ResourceType, int> _stocks(Player player) =>
    player.resources.map((t, r) => MapEntry(t, r.amount));

void main() {
  test('a turn plays the human player unless told otherwise', () {
    final two = TwoPlayerGame.create();
    final turn = ScriptTurn(
      game: two.game,
      random: Random(1),
      log: <ScriptLogEntry>[],
    );

    expect(turn.player, same(two.human));
  });

  test('a turn given another player acts for that player only', () {
    final two = TwoPlayerGame.create();
    final humanLevels = _levels(two.human);
    final humanStocks = _stocks(two.human);
    final rivalLevels = _levels(two.rival);
    final rivalStocks = _stocks(two.rival);
    final turn = ScriptTurn(
      game: two.game,
      random: Random(1),
      log: <ScriptLogEntry>[],
      player: two.rival,
    );

    expect(turn.player, same(two.rival));
    expect(
      turn
          .perform(
            UpgradeBuildingAction(buildingType: BuildingType.headquarters),
          )
          .isSuccess,
      isTrue,
    );
    const EconomyStrategy().playTurn(turn);

    expect(_levels(two.rival), isNot(rivalLevels));
    expect(_stocks(two.rival), isNot(rivalStocks));
    expect(_levels(two.human), humanLevels);
    expect(_stocks(two.human), humanStocks);
  });
}
