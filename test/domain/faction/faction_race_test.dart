import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/game/victory_checker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/faction_race.dart';

void main() {
  test('left alone, a faction tames the volcano before turn 160', () {
    var finished = 0;
    for (var seed = 1; seed <= 6; seed++) {
      final Game game = playLoneFaction(
        FactionPersonality.murenaHorde,
        seed,
        limit: 160,
      );
      final Player? winner = VictoryChecker.winnerOf(game);
      if (winner != null && winner.id != game.humanPlayerId) finished++;
    }

    expect(finished, greaterThanOrEqualTo(5));
  });

  test('it beats a human who does nothing, and names itself', () {
    final Game game = playLoneFaction(FactionPersonality.murenaHorde, 3);
    final Player winner = VictoryChecker.winnerOf(game)!;

    expect(winner.name, FactionPersonality.murenaHorde.label);
    expect(winner.buildings[BuildingType.volcanicKernel]!.level, 10);
    expect(VictoryChecker.check(game..status = GameStatus.playing),
        GameStatus.defeat);
  });
}
