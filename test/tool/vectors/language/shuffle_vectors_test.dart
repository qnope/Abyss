import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/vectors/language/random_seeds.dart';
import '../../../../tool/vectors/language/shuffle_vectors.dart';
import '../spec/dart_random_spec.dart';

List<Map<String, Object?>> _cases(String section) => ShuffleVectors
    .file
    .sections[section]!
    .cases()
    .cast<Map<String, Object?>>();

/// The shuffle of `ListBase.shuffle` in the SDK's
/// `sdk/lib/collection/list.dart`: from the end, each element is swapped
/// with one drawn among those not placed yet, itself included.
List<int> _specShuffle(DartRandomSpec random, int length) {
  final list = List<int>.generate(length, (i) => i);
  int left = length;
  while (left > 1) {
    final int pos = random.nextInt(left);
    left -= 1;
    final int tmp = list[left];
    list[left] = list[pos];
    list[pos] = tmp;
  }
  return list;
}

void main() {
  group('ShuffleVectors', () {
    test('shuffle every length with every seed into a permutation', () {
      final cases = _cases('shuffle');
      expect(
        cases,
        hasLength(ShuffleVectors.lengths.length * RandomSeeds.few.length),
      );
      for (final c in cases) {
        final length = c['length']! as int;
        expect((c['out']! as List<int>).toSet(), hasLength(length));
      }
      expect(ShuffleVectors.lengths, containsAll([0, 1, 2, 3, 4, 10, 400]));
    });

    test('are what the specification gives, the generator left as far', () {
      for (final c in _cases('shuffle')) {
        final random = DartRandomSpec(c['seed']! as int);
        expect(_specShuffle(random, c['length']! as int), c['out']);
        expect(random.nextInt(4294967296), c['next']);
      }
    });

    test('go on with the same generator for a second list', () {
      for (final c in _cases('twice')) {
        final random = DartRandomSpec(c['seed']! as int);
        expect(c['out'], [_specShuffle(random, 7), _specShuffle(random, 7)]);
        expect((c['out']! as List)[0], isNot((c['out']! as List)[1]));
      }
    });
  });
}
