import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/game/victory_checker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/faction_race.dart';

void main() {
  for (final personality in const [
    FactionPersonality.wreckPillagers,
    FactionPersonality.pearlOrder,
    FactionPersonality.anglerCult,
  ]) {
    test('left alone, ${personality.label} tames the volcano before 160', () {
      final games = <Game>[
        for (var seed = 1; seed <= 6; seed++)
          playLoneFaction(personality, seed, limit: 160),
      ];
      final winners = <Game>[
        for (final Game g in games)
          if (VictoryChecker.winnerOf(g) != null) g,
      ];

      expect(winners.length, greaterThanOrEqualTo(5));
      for (final Game game in winners) {
        final Player winner = VictoryChecker.winnerOf(game)!;
        expect(winner.name, personality.label);
        expect(winner.buildings[BuildingType.volcanicKernel]!.level, 10);
        // The human did nothing, so the faction's win is the human's defeat.
        expect(
          VictoryChecker.check(game..status = GameStatus.playing),
          GameStatus.defeat,
        );
      }
    });
  }
}
