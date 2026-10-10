import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_generation_result.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/map/world_generator.dart';
import '../../helpers/map_fingerprint.dart';

int _count(MapGenerationResult r, TransitionBaseType type) =>
    r.map.cells.where((c) => c.transitionBase?.type == type).length;

int _distance(GridPosition a, GridPosition b) =>
    [(a.x - b.x).abs(), (a.y - b.y).abs()].reduce((m, d) => m > d ? m : d);

void main() {
  const sizes = {1: 20, 2: 20, 3: 20, 4: 26, 6: 26, 7: 32, 11: 32};

  group('MapGenerator with several players', () {
    test('a lone player has one base, the first one', () {
      final r = MapGenerator.generate(seed: 5);
      expect(r.bases, [GridPosition(x: r.baseX, y: r.baseY)]);
    });

    for (final entry in sizes.entries) {
      final players = entry.key;
      group('$players players', () {
        for (final seed in [1, 42, 777]) {
          final r = MapGenerator.generate(seed: seed, playerCount: players);
          final size = entry.value;

          test('seed $seed: map is ${size}x$size', () {
            expect(r.map.width, size);
            expect(r.map.height, size);
            expect(r.map.cells.length, size * size);
          });

          test('seed $seed: one base per player, the first leading', () {
            expect(r.bases.length, players);
            expect(r.bases.first, GridPosition(x: r.baseX, y: r.baseY));
            expect(r.bases.toSet().length, players);
          });

          test('seed $seed: bases are well apart', () {
            final minimum = players <= 2 ? 7 : 5;
            for (var i = 0; i < players; i++) {
              for (var j = i + 1; j < players; j++) {
                expect(
                  _distance(r.bases[i], r.bases[j]),
                  greaterThanOrEqualTo(minimum),
                );
              }
            }
          });

          test('seed $seed: bases sit on empty cells, off the centre', () {
            for (final b in r.bases) {
              expect(r.map.cellAt(b.x, b.y).content, CellContentType.empty);
              expect(r.map.cellAt(b.x, b.y).lair, isNull);
              expect(r.map.cellAt(b.x, b.y).transitionBase, isNull);
            }
            for (final b in r.bases.skip(1)) {
              expect(b, isNot(GridPosition(x: size ~/ 2, y: size ~/ 2)));
            }
          });

          test('seed $seed: no lair within 2 cells of any base', () {
            for (final b in r.bases) {
              for (var y = b.y - 2; y <= b.y + 2; y++) {
                for (var x = b.x - 2; x <= b.x + 2; x++) {
                  if (x < 0 || y < 0 || x >= size || y >= size) continue;
                  expect(
                    r.map.cellAt(x, y).content,
                    isNot(CellContentType.monsterLair),
                  );
                }
              }
            }
          });

          test('seed $seed: enough Failles, lairs scale with the map', () {
            final extra = (players - 1) ~/ 2;
            expect(_count(r, TransitionBaseType.faille), 4 + extra);
            final lairs =
                r.map.cells
                    .where((c) => c.content == CellContentType.monsterLair)
                    .length;
            expect(lairs, greaterThanOrEqualTo(5));
          });
        }

        test('is deterministic by seed', () {
          final a = MapGenerator.generate(seed: 9, playerCount: players);
          final b = MapGenerator.generate(seed: 9, playerCount: players);
          expect(mapFingerprint(a.map), mapFingerprint(b.map));
          expect(a.bases, b.bases);
        });
      });
    }

    test('one more Cheminée per two more players on level 2', () {
      for (final players in [1, 2, 4, 7, 11]) {
        final r = MapGenerator.generate(
          seed: 3,
          level: 2,
          playerCount: players,
        );
        expect(_count(r, TransitionBaseType.cheminee), 3 + (players - 1) ~/ 2);
      }
    });

    test('rejects a player count off the 1 to 11 range', () {
      expect(
        () => MapGenerator.generate(seed: 1, playerCount: 0),
        throwsArgumentError,
      );
      expect(
        () => MapGenerator.generate(seed: 1, playerCount: 12),
        throwsArgumentError,
      );
    });
  });

  group('WorldGenerator.generate', () {
    test('builds the three levels of the same size', () {
      final world = WorldGenerator.generate(seed: 8, playerCount: 4);
      expect(world.keys, [1, 2, 3]);
      for (final r in world.values) {
        expect(r.map.width, 26);
      }
    });

    test('levels 2 and 3 carry the passages of the level above', () {
      final world = WorldGenerator.generate(seed: 8, playerCount: 7);
      for (final level in [2, 3]) {
        final passages = passagesOf(world[level - 1]!.map);
        expect(passages, isNotEmpty);
        for (final e in passages.entries) {
          final cell = world[level]!.map.cellAt(e.key.x, e.key.y);
          expect(cell.content, CellContentType.passage);
          expect(cell.passageName, e.value);
        }
      }
      expect(
        world[3]!.map.cellAt(16, 16).content,
        CellContentType.volcanicKernel,
      );
    });

    test('is deterministic and keeps level 1 as generate gives it', () {
      final a = WorldGenerator.generate(seed: 8, playerCount: 4);
      final b = WorldGenerator.generate(seed: 8, playerCount: 4);
      for (final level in [1, 2, 3]) {
        expect(mapFingerprint(a[level]!.map), mapFingerprint(b[level]!.map));
      }
      final l1 = MapGenerator.generate(seed: 8, playerCount: 4);
      expect(mapFingerprint(a[1]!.map), mapFingerprint(l1.map));
    });
  });
}
