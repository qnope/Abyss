import 'dart:math';

import 'package:abyss/domain/event/effects/wreck_effect.dart';
import 'package:abyss/domain/event/event_effects.dart';
import 'package:abyss/domain/event/event_rules.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:flutter_test/flutter_test.dart';

import 'wreck_test_helper.dart';

const _wreck = WreckEffect();

/// Sinks a wreck at the end of turn 12 with the dice of [seed].
GridPosition? _sink(Game game, Player player, int seed) {
  _wreck.onDraw(game, player, turn: 12, random: Random(seed));
  return player.eventState.wreckPosition;
}

void main() {
  test('a wreck sinks on a hidden empty cell at the edge of the explored '
      'area until the end of turn 17', () {
    for (var seed = 0; seed < 40; seed++) {
      final player = wreckPlayer();
      final game = wreckGame(player);
      final at = _sink(game, player, seed)!;
      expect(wreckRing, contains(at), reason: 'seed $seed');
      expect(player.revealedCells, isNot(contains(at)));
      expect(game.currentMap.cellAt(at.x, at.y).content, CellContentType.wreck);
      expect(player.eventState.wreckUntilTurn, 12 + EventRules.wreckTurns);
    }
  });

  test('only an empty cell can take the wreck', () {
    final free = GridPosition(x: 6, y: 2);
    for (var seed = 0; seed < 10; seed++) {
      final map = wreckMap(
        contents: {
          for (final p in wreckRing)
            if (p != free) p: CellContentType.ruins,
        },
      );
      final player = wreckPlayer();
      expect(_sink(wreckGame(player, map: map), player, seed), free);
    }
  });

  test('the dice pick the cell, whatever the order of the revealed cells', () {
    final picks = <GridPosition>{};
    for (var seed = 0; seed < 40; seed++) {
      final player = wreckPlayer();
      final at = _sink(wreckGame(player), player, seed)!;
      final reversed = wreckPlayer(
        revealed: squareAround(4, 4, 1).reversed.toList(),
      );
      expect(_sink(wreckGame(reversed), reversed, seed), at);
      picks.add(at);
    }
    expect(picks.length, greaterThan(5));
  });

  test('a wreck never sinks on a cell the scouts may not explore', () {
    final base = GridPosition(x: 4, y: 4);
    final ring = squareAround(4, 4, 1)..remove(base);
    for (var seed = 0; seed < 40; seed++) {
      final player = wreckPlayer(revealed: ring);
      expect(_sink(wreckGame(player), player, seed), isNot(base));
    }
  });

  test('a wreck sinks with the dice of the draw', () {
    final player = wreckPlayer();
    final random = Random(5);
    _wreck.onDraw(wreckGame(player), player, turn: 12, random: random);
    expect(random.nextInt(1000), isNot(Random(5).nextInt(1000)));
  });

  test('no wreck is drawn when no hidden empty cell borders the area', () {
    final player = wreckPlayer();
    final full = wreckMap(
      contents: {for (final p in wreckRing) p: CellContentType.monsterLair},
    );
    expect(_wreck.allowedAt(wreckGame(player, map: full), player, 12), false);
    expect(
      EventEffects.excludedAt(wreckGame(player, map: full), player, 12),
      contains(RandomEventType.wreck),
    );
    expect(_wreck.allowedAt(wreckGame(player), player, 12), isTrue);
  });

  test('no wreck is drawn on a fully explored map', () {
    final player = wreckPlayer(revealed: squareAround(4, 4, 4));
    expect(_wreck.allowedAt(wreckGame(player), player, 12), isFalse);
  });

  test('no second wreck is drawn while one lies on the map', () {
    final player = wreckPlayer();
    final game = wreckGame(player);
    _sink(game, player, 1);
    expect(_wreck.allowedAt(game, player, 14), isFalse);
  });

  test('the wreck borders a wide explored area on a large map', () {
    const size = 120;
    final revealed = [
      for (var y = 0; y < size; y++)
        for (var x = 0; x < size - 2; x++) GridPosition(x: x, y: y),
    ];
    final player = wreckPlayer(revealed: revealed);
    final game = wreckGame(player, map: wreckMap(size: size));
    final at = _sink(game, player, 3)!;
    expect(at.x, size - 2);
  });
}
