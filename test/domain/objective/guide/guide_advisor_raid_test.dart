import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/guide_helpers.dart';

void main() {
  test('the first raid announced points at the harpoonists', () {
    final game = guideGame(ObjectiveId.firstRaid)..turn = 10;
    game.humanPlayer.raidState.announce(
      const MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 5),
      12,
    );

    final advice = adviceOf(game)!;

    expect(advice.text, contains('fin du tour 12'));
    expect(advice.text, contains('Harponneurs'));
    expect(advice.text, contains('Armée'));
    expect(advice.target, const GuideTarget.unit(UnitType.harpoonist));
  });

  test('the raid announced, harpoonists recruited, asks to end the turn', () {
    final game = guideGame(ObjectiveId.firstRaid)..turn = 10;
    final player = game.humanPlayer;
    player.raidState.announce(
      const MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 5),
      12,
    );
    player.recruitedUnitTypes.add(UnitType.harpoonist);

    final advice = adviceOf(game)!;

    expect(advice.text, contains('fin du tour 12'));
    expect(advice.target, const GuideTarget.endTurn());
  });
}
