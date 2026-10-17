import 'package:abyss/domain/script/faction_tally.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FactionTally sums', () {
    test('merge sums counters and held-kernel attacks', () {
      final FactionTally a =
          FactionTally()
            ..bump('f1', 'upgrade', 2)
            ..heldKernelByLevel[7] = 1;
      final FactionTally b =
          FactionTally()
            ..bump('f1', 'upgrade')
            ..bump('f2', 'spy')
            ..heldKernelByLevel[7] = 2
            ..heldKernelByLevel[8] = 1;
      a.merge(b);
      expect(a.of('f1', 'upgrade'), 3);
      expect(a.of('f2', 'spy'), 1);
      expect(a.heldKernelByLevel, <int, int>{7: 3, 8: 1});
    });

    test('factionIds leaves the human out, sorted', () {
      final FactionTally tally =
          FactionTally()
            ..bump('f2', 'spy')
            ..bump('human', 'spy')
            ..bump('f1', 'spy');
      expect(tally.factionIds, <String>['f1', 'f2']);
    });

    test('perTurn divides by the turns the player took part in', () {
      final FactionTally tally =
          FactionTally()
            ..bump('f1', 'upgrade', 6)
            ..played('f1', 2)
            ..played('f1', 1);
      expect(tally.perTurn('f1', 'upgrade'), 2);
      expect(tally.perTurn('f2', 'upgrade'), 0);
    });

    test('factionMean is per faction turn, over the factions only', () {
      final FactionTally tally =
          FactionTally()
            ..bump('f1', 'upgrade', 4)
            ..played('f1', 2)
            ..bump('f2', 'spy')
            ..played('f2', 6)
            ..bump('human', 'upgrade', 100)
            ..played('human', 8);
      expect(tally.factionMean('upgrade'), 0.5);
      expect(FactionTally().factionMean('upgrade'), 0);
    });
  });
}
