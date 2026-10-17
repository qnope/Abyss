import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/raid/announced_attack.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/faction/faction_turn.dart';
import 'package:abyss/domain/faction/faction_war.dart';
import 'package:abyss/domain/faction/kernel_siege.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/kernel_war_helper.dart';

/// A personality that does not look at kernels first, on a slow cadence.
const FactionPersonality _order = FactionPersonality.pearlOrder;

/// The owner holds the kernel at [level] with a small garrison; the
/// attacker stands ready on the volcano level and, with its base army,
/// has seen the base of the owner.
KernelWar _scene(int level) {
  final war =
      KernelWar(
          kernelLevel: level,
          personalities: [_order, FactionPersonality.murenaHorde],
        )
        ..arm()
        ..garrison(smallGarrison);
  war.put(war.attacker, 1, {...horde, UnitType.scout: 2});
  war.attacker.addRevealedCell(
    1,
    GridPosition(x: war.owner.baseX, y: war.owner.baseY),
  );
  return war;
}

void _toTurn(KernelWar war, bool Function(int turn) wanted) {
  final int limit = war.game.turn + 30;
  while (!wanted(war.game.turn)) {
    if (++war.game.turn > limit) fail('no such turn');
  }
}

void _onSlot(KernelWar war) => _toTurn(war, (t) => FactionWar.isDue(t, _order));

void _offSlot(KernelWar war, {required bool siegeTurn}) => _toTurn(
  war,
  (t) =>
      !FactionWar.isDue(t, _order) &&
      KernelSiege.isOffSlot(t, _order) == siegeTurn,
);

void _play(KernelWar war) => FactionWar.play(
  FactionTurn(
    game: war.game,
    player: war.attacker,
    executor: ActionExecutor(),
    seeds: Random(2),
  ),
  _order,
);

Iterable<BaseAssaultEntry> _hits(KernelWar war, {required bool kernel}) => war
    .owner
    .historyEntries
    .whereType<BaseAssaultEntry>()
    .where((e) => (e.postName == 'volcanicKernel') == kernel);

void main() {
  test('a seen kernel held at level 7 is besieged before the base', () {
    final war = _scene(7);
    _onSlot(war);

    _play(war);

    expect(war.kernelOf(war.owner), 6);
    expect(_hits(war, kernel: false), isEmpty);
  });

  test('at level 6 the base still comes first, as before', () {
    final war = _scene(6);
    _onSlot(war);

    _play(war);

    expect(war.kernelOf(war.owner), 6);
    expect(_hits(war, kernel: false), hasLength(1));
  });

  test('an unseen kernel at level 7 is left alone', () {
    final war = _scene(7);
    war.attacker.revealedCellsPerLevel[3] = [];
    _onSlot(war);

    _play(war);

    expect(war.kernelOf(war.owner), 7);
    expect(_hits(war, kernel: true), isEmpty);
  });

  test('a pending attack on the human does not hold the siege back', () {
    final war = _scene(7);
    _onSlot(war);
    war.human.raidState.attacks.add(
      AnnouncedAttack(
        attackerId: war.attacker.id,
        units: const {UnitType.harpoonist: 1},
        arrivalTurn: war.game.turn + 1,
        seed: 1,
      ),
    );

    _play(war);

    expect(war.kernelOf(war.owner), 6);
  });

  test('off its slot, it besieges a hot kernel every other turn', () {
    final war = _scene(7);
    _offSlot(war, siegeTurn: false);
    _play(war);
    expect(war.kernelOf(war.owner), 7);

    _offSlot(war, siegeTurn: true);
    _play(war);
    expect(war.kernelOf(war.owner), 6);
    expect(_hits(war, kernel: false), isEmpty);
  });

  test('off its slot, a kernel below level 7 is left alone', () {
    final war = _scene(6);
    _offSlot(war, siegeTurn: true);

    _play(war);

    expect(war.kernelOf(war.owner), 6);
  });
}
