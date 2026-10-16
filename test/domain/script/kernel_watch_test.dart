import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/script/faction_tally.dart';
import 'package:abyss/domain/script/idle_script.dart';
import 'package:abyss/domain/script/kernel_watch.dart';
import 'package:abyss/domain/script/script_library.dart';
import 'package:abyss/domain/script/script_log_entry.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/kernel_war_helper.dart';

FactionTally _watch(KernelWar war) {
  final FactionTally tally = FactionTally();
  KernelWatch(const IdleScript(), tally).playTurn(
    ScriptTurn(
      game: war.game,
      random: SeededRandom(1),
      log: <ScriptLogEntry>[],
    ),
  );
  return tally;
}

void main() {
  group('KernelWatch', () {
    test('notes the held kernel level of the turn', () {
      final KernelWar war = KernelWar(kernelLevel: 4);
      expect(_watch(war).kernelLevelAt, <int, int>{12: 4});
    });

    test('notes 0 when nobody holds the kernel', () {
      final KernelWar war = KernelWar(kernelLevel: 8);
      final at = war.at;
      final map = war.game.levels[KernelGarrison.volcanoLevel]!;
      map.setCell(
        at.x,
        at.y,
        map.cellAt(at.x, at.y).copyWith(collectedBy: null),
      );
      war.arm();
      final FactionTally tally = _watch(war);
      expect(tally.kernelLevelAt, <int, int>{12: 0});
      expect(tally.of(war.attacker.id, 'kernelChance'), 0);
    });

    test('a level 7 kernel is a chance for an armed faction, seen or not', () {
      final KernelWar war = KernelWar(kernelLevel: 7)..arm();
      final FactionTally tally = _watch(war);
      expect(tally.of(war.attacker.id, 'kernelChance'), 1);
      expect(tally.of(war.attacker.id, 'kernelSeen'), 1);
      expect(tally.of(war.owner.id, 'kernelChance'), 0);
    });

    test('a kernel below level 7 is no chance', () {
      final KernelWar war = KernelWar(kernelLevel: 6)..arm();
      expect(_watch(war).of(war.attacker.id, 'kernelChance'), 0);
    });

    test('seeing any cell of the volcano counts as seeing the kernel', () {
      final KernelWar war = KernelWar(kernelLevel: 7)..arm();
      final Player a = war.attacker;
      a.revealedCellsPerLevel[KernelGarrison.volcanoLevel]!.remove(war.at);
      expect(_watch(war).of(a.id, 'kernelSeen'), 0);
      a.addRevealedCell(
        KernelGarrison.volcanoLevel,
        GridPosition(x: war.at.x + 1, y: war.at.y + 1),
      );
      expect(_watch(war).of(a.id, 'kernelSeen'), 1);
    });

    test('keeps the traits of the inner script', () {
      final KernelWatch watch = KernelWatch(
        ScriptLibrary.byName('conquest'),
        FactionTally(),
      );
      expect(watch.name, 'conquest');
      expect(watch.playerName, 'conquest');
      expect(watch.factionsPlay, isTrue);
      expect(watch.lastTurn, isNull);
    });
  });
}
