import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/vectors/language/random_seeds.dart';
import '../../../../tool/vectors/language/random_vectors.dart';
import '../spec/dart_random_spec.dart';

List<Map<String, Object?>> _cases(String section) =>
    RandomVectors.file.sections[section]!.cases().cast<Map<String, Object?>>();

void main() {
  group('RandomSeeds', () {
    test('span small, negative, game-sized and 64-bit seeds', () {
      const seeds = RandomSeeds.all;
      expect(seeds.toSet(), hasLength(seeds.length));
      expect(seeds, containsAll([0, 1, 0x7FFFFFFE, 0x7FFFFFFF, -1]));
      expect(seeds.where((s) => s > 4294967296), isNotEmpty);
      expect(seeds, contains(9223372036854775807));
      expect(seeds, contains(-9223372036854775808));
      expect(RandomSeeds.all, containsAll(RandomSeeds.few));
    });

    test('hold the one seed the mix turns into zero', () {
      expect(RandomSeeds.mixedToZero * 2097151, 1);
      expect(DartRandomSpec.mix(RandomSeeds.mixedToZero), 0x5a17);
      expect(RandomSeeds.all, contains(RandomSeeds.mixedToZero));
    });

    test('bound the draws by what the rules use and by the limits', () {
      expect(
        RandomSeeds.bounds,
        containsAll([1, 2, 31, 41, 81, 101, 0x7FFFFFFF, 4294967296]),
      );
    });
  });

  group('RandomVectors', () {
    test('record the draws of the VM for every seed and bound', () {
      final cases = _cases('nextInt');
      expect(
        cases,
        hasLength(RandomSeeds.all.length * RandomSeeds.bounds.length),
      );
      final first = cases.firstWhere((c) => c['seed'] == 42 && c['max'] == 6);
      final random = Random(42);
      expect(first['out'], [for (var i = 0; i < 6; i++) random.nextInt(6)]);
    });

    test('are what the specification draws, call for call', () {
      for (final c in _cases('nextInt')) {
        final spec = DartRandomSpec(c['seed']! as int);
        final max = c['max']! as int;
        expect(
          [for (var i = 0; i < 6; i++) spec.nextInt(max)],
          c['out'],
          reason: 'seed ${c['seed']} max $max',
        );
      }
      for (final c in _cases('nextDouble')) {
        final spec = DartRandomSpec(c['seed']! as int);
        expect([for (var i = 0; i < 12; i++) spec.nextDouble()], c['out']);
      }
      for (final c in _cases('nextBool')) {
        final spec = DartRandomSpec(c['seed']! as int);
        expect([for (var i = 0; i < 40; i++) spec.nextBool()], c['out']);
      }
      for (final c in [..._cases('mixed'), ..._cases('seededRandom')]) {
        final spec = DartRandomSpec(c['seed']! as int);
        expect(RandomVectors.play(spec, RandomVectors.calls), c['out']);
      }
    });

    test('follow a generator far along its sequence', () {
      for (final c in _cases('afterMany')) {
        final spec = DartRandomSpec(c['seed']! as int);
        for (var i = 0; i < (c['skip']! as int); i++) {
          spec.nextInt(4294967296);
        }
        final max = c['max']! as int;
        expect([for (var i = 0; i < 6; i++) spec.nextInt(max)], c['out']);
      }
    });

    test('mix every kind of call, the bounds of the game among them', () {
      expect(RandomVectors.calls, containsAll(['double', 'bool', 0x7FFFFFFF]));
      final outs = {for (final c in _cases('mixed')) '${c['out']}'};
      expect(outs, hasLength(RandomSeeds.all.length));
    });

    test('tell the bounds nextInt refuses, as the specification does', () {
      for (final c in _cases('refused')) {
        expect(c['throws'], isTrue, reason: '${c['max']}');
        expect(
          () => DartRandomSpec(1).nextInt(c['max']! as int),
          throwsRangeError,
        );
      }
    });

    test('show SeededRandom draws as Random and keeps its seed', () {
      for (final c in _cases('seededRandom')) {
        expect(c['keptSeed'], c['seed']);
        expect(
          c['out'],
          RandomVectors.play(Random(c['seed']! as int), RandomVectors.calls),
        );
      }
    });
  });
}
