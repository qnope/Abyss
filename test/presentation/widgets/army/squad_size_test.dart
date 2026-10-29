import 'package:abyss/presentation/widgets/army/squad_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SquadSize.of', () {
    const tiers = {
      0: 0,
      1: 1,
      2: 2,
      5: 2,
      6: 3,
      15: 3,
      16: 4,
      30: 4,
      31: 5,
      60: 5,
      61: 6,
      1000: 6,
    };
    for (final MapEntry(key: count, value: figures) in tiers.entries) {
      test('$count units stand as $figures figures', () {
        expect(SquadSize.of(count), figures);
      });
    }

    test('never stands more figures than there are slots', () {
      expect(SquadSize.of(1 << 30), SquadSize.max);
    });

    test('treats a negative count as an empty squad', () {
      expect(SquadSize.of(-3), 0);
    });
  });
}
