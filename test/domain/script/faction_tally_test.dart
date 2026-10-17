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
  });
}
