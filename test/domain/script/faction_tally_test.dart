import 'package:abyss/domain/script/faction_tally.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _move(
  String verb, [
  Map<String, Object?> more = const {},
]) => <String, Object?>{'do': verb, ...more};

void main() {
  group('FactionTally', () {
    test('counts each verb per player, a move without player is human', () {
      final FactionTally tally =
          FactionTally()..addJournal(<(int, List<Map<String, Object?>>)>[
            (
              1,
              [
                _move('upgrade'),
                _move('upgrade', {'player': 'f1'}),
              ],
            ),
            (
              2,
              [
                _move('upgrade', {'player': 'f1'}),
              ],
            ),
          ]);
      expect(tally.of('human', 'upgrade'), 1);
      expect(tally.of('f1', 'upgrade'), 2);
      expect(tally.of('f2', 'upgrade'), 0);
    });

    test(
      'counts explorations and collections by level, level 1 by default',
      () {
        final FactionTally tally =
            FactionTally()..addJournal(<(int, List<Map<String, Object?>>)>[
              (
                1,
                [
                  _move('explore', {'player': 'f1'}),
                  _move('explore', {'player': 'f1', 'level': 3}),
                  _move('collect', {'player': 'f1', 'level': 2}),
                ],
              ),
            ]);
        expect(tally.of('f1', 'explore'), 2);
        expect(tally.of('f1', 'explore@1'), 1);
        expect(tally.of('f1', 'explore@3'), 1);
        expect(tally.of('f1', 'collect@2'), 1);
      },
    );

    test('counts unlocks and research by branch', () {
      final FactionTally tally =
          FactionTally()..addJournal(<(int, List<Map<String, Object?>>)>[
            (
              1,
              [
                _move('unlock', {'player': 'f1', 'branch': 'explorer'}),
                _move('research', {'player': 'f1', 'branch': 'explorer'}),
                _move('research', {'player': 'f1', 'branch': 'military'}),
              ],
            ),
          ]);
      expect(tally.of('f1', 'unlock:explorer'), 1);
      expect(tally.of('f1', 'research:explorer'), 1);
      expect(tally.of('f1', 'research:military'), 1);
      expect(tally.of('f1', 'research'), 2);
    });

    test('counts attacks on the human base apart', () {
      final FactionTally tally =
          FactionTally()..addJournal(<(int, List<Map<String, Object?>>)>[
            (
              1,
              [
                _move('attackPlayer', {'player': 'f1', 'target': 'human'}),
                _move('attackPlayer', {'player': 'f1', 'target': 'f2'}),
              ],
            ),
          ]);
      expect(tally.of('f1', 'attackPlayer'), 2);
      expect(tally.of('f1', 'attackHuman'), 1);
    });

    test('files faction held-kernel attacks under the kernel level of their '
        'turn', () {
      final FactionTally tally = FactionTally()..kernelLevelAt[2] = 7;
      tally.addJournal(<(int, List<Map<String, Object?>>)>[
        (
          1,
          [
            _move('attackHeldKernel', {'player': 'f1'}),
          ],
        ),
        (
          2,
          [
            _move('attackHeldKernel'),
            _move('attackHeldKernel', {'player': 'f1'}),
            _move('attackHeldKernel', {'player': 'f2'}),
          ],
        ),
      ]);
      expect(tally.heldKernelByLevel, <int, int>{0: 1, 7: 2});
      expect(tally.of('human', 'attackHeldKernel'), 1);
    });

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
