import 'package:abyss/domain/action/action_type.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/reference/reference_game.dart';
import 'package:abyss/domain/reference/snapshot_sections.dart';
import 'package:flutter_test/flutter_test.dart';

import 'committed_games.dart';

void main() {
  final List<CommittedGame> games = committedGames();

  Set<String> union(Map<String, Object?> Function(CommittedGame g) of) =>
      <String>{for (final CommittedGame g in games) ...of(g).keys};

  Iterable<Object?> milestone(String name) =>
      games.map((CommittedGame g) => g.milestones[name]);

  group('the reference games of reference/games', () {
    test('are about fifteen, each one an exact journal in the format '
        'of today', () {
      expect(games.length, greaterThanOrEqualTo(15));
      for (final CommittedGame g in games) {
        expect(g.json['format'], ReferenceGame.format, reason: g.name);
        expect(g.json['sections'], SnapshotSections.names, reason: g.name);
        expect(g.journal['exact'], isTrue, reason: g.name);
      }
    });

    test('execute every type of action', () {
      expect(union((g) => g.actions), {
        for (final ActionType t in ActionType.values) t.name,
      });
    });

    test('draw every type of random event', () {
      expect(union((g) => g.events), {
        for (final RandomEventType t in RandomEventType.values) t.name,
      });
    });

    test('reach every status a scripted game can reach: free play is '
        'chosen on the victory screen', () {
      expect(games.map((g) => g.status).toSet(), {
        for (final GameStatus s in GameStatus.values)
          if (s != GameStatus.freePlay) s.name,
      });
    });

    test('are played at every difficulty, alone and against every '
        'faction', () {
      expect(games.map((g) => g.source.difficulty).toSet(), {
        ...Difficulty.values,
      });
      expect(games.where((g) => g.source.factions.isEmpty), isNotEmpty);
      expect(
        {for (final CommittedGame g in games) ...g.source.factions},
        {...FactionPersonality.values},
      );
      expect(games.map((g) => g.source.seed).toSet().length, greaterThan(10));
    });

    test('reach the late game: the volcano tamed, by the human and by '
        'a faction, past turn 100', () {
      expect(milestone('kernelCaptured').nonNulls, isNotEmpty);
      expect(milestone('winner'), contains('human'));
      expect(
        milestone('winner').nonNulls.where((Object w) => w != 'human'),
        isNotEmpty,
      );
      expect(
        games.map((g) => g.turn).reduce((a, b) => a > b ? a : b),
        greaterThan(100),
      );
    });

    test('win and lose what can be won and lost: the Faille against '
        'the Léviathan, raids, kraken waves, a faction', () {
      expect(milestone('leviathanHeld'), containsAll([true, false]));
      for (final String name in [
        'raidsRepelled',
        'raidsLost',
        'wavesRepelled',
        'wavesLost',
        'fallenFactions',
      ]) {
        expect(
          milestone(name).cast<int>().where((int n) => n > 0),
          isNotEmpty,
          reason: name,
        );
      }
    });
  });
}
