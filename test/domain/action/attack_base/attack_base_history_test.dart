import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/raid/noise_rules.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/base_attack_helper.dart';

void main() {
  test('both players keep a history entry of the attack', () {
    final two = assaultGame();
    station(two.human, horde);
    two.rival.resources[ResourceType.coral]!.amount = 1000;

    ActionExecutor().execute(strike(two, horde), two.game, two.human);

    final mine = two.human.historyEntries.whereType<BaseAssaultEntry>().single;
    final theirs =
        two.rival.historyEntries.whereType<BaseAssaultEntry>().single;
    expect(mine.defending, isFalse);
    expect(theirs.defending, isTrue);
    expect(mine.opponentName, 'rival');
    expect(theirs.opponentName, 'human');
    expect(mine.victory, isTrue);
    expect(theirs.victory, isTrue);
    expect(mine.turn, 12);
    expect(theirs.turn, 12);
    expect(mine.headquartersAfter, 4);
    expect(mine.loot[ResourceType.coral], 300);
    expect(theirs.pillaged[ResourceType.coral], 300);
  });

  test('a lost attack is recorded for both players too', () {
    final two = assaultGame();
    station(two.human, {UnitType.scout: 2});
    station(two.rival, wall);
    setLevel(two.rival, BuildingType.coralCitadel, 2);

    ActionExecutor().execute(
      strike(two, {UnitType.scout: 2}),
      two.game,
      two.human,
    );

    expect(
      two.human.historyEntries.whereType<BaseAssaultEntry>().single.victory,
      isFalse,
    );
    expect(
      two.rival.historyEntries.whereType<BaseAssaultEntry>().single.victory,
      isFalse,
    );
  });

  test('the attack never counts as a lost raid', () {
    final two = assaultGame();
    station(two.human, horde);
    station(two.rival, {});

    ActionExecutor().execute(strike(two, horde), two.game, two.human);

    for (final p in [two.human, two.rival]) {
      expect(p.raidState.lostInARow, 0);
      expect(p.raidState.raidsLost, 0);
      expect(p.raidState.raidsRepelled, 0);
    }
  });

  test('attacking makes the noise of a fight', () {
    final two = assaultGame();
    station(two.human, horde);
    final before = two.human.raidState.noise;

    ActionExecutor().execute(strike(two, horde), two.game, two.human);

    expect(two.human.raidState.noise - before, NoiseRules.perFight);
    expect(two.rival.raidState.noise, 0);
  });
}
