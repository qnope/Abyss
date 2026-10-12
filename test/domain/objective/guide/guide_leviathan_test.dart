import 'package:abyss/domain/leviathan/leviathan_defence_advisor.dart';
import 'package:abyss/domain/objective/guide/guide_advice.dart';
import 'package:abyss/domain/objective/guide/guide_advisor.dart';
import 'package:abyss/domain/objective/guide/guide_message.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/domain/objective/objective_migration.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/post_attack_helper.dart';
import '../../leviathan/leviathan_scene.dart';

/// The scene on the turn the guardians strike, the tutorial on.
PostWar _strikeTurn({bool tutorial = true}) {
  final war = leviathanScene();
  war.playUntil(war.strikeTurn);
  ObjectiveMigration.stateOf(war.game, war.human).tutorialEnabled = tutorial;
  return war;
}

GuideAdvice? _advice(PostWar war) => GuideAdvisor.of(war.game, war.human);

void main() {
  test('comes first on the turn the guardians strike', () {
    final war = _strikeTurn();
    final needed = LeviathanDefenceAdvisor.unitsFor(war.game, war.human, 2)!;
    expect(
      _advice(war),
      GuideAdvice(
        GuideLeviathanReturn(2, missing: needed),
        GuideTarget.cell(war.level, war.at),
      ),
    );
  });

  test('counts the units already on level 2', () {
    final war = _strikeTurn();
    war.put(war.human, 2, {UnitType.harpoonist: 1});
    final needed = LeviathanDefenceAdvisor.unitsFor(war.game, war.human, 2)!;
    expect(
      _advice(war)!.message,
      GuideLeviathanReturn(2, missing: needed - 1),
    );
  });

  test('asks for none once level 2 should hold', () {
    final war = _strikeTurn();
    war.put(war.human, 2, {UnitType.guardian: 200, UnitType.harpoonist: 200});
    expect(_advice(war)!.message, const GuideLeviathanReturn(2));
  });

  test('says nothing before the turn they strike', () {
    final war = leviathanScene();
    war.playUntil(war.strikeTurn - 1);
    ObjectiveMigration.stateOf(war.game, war.human).tutorialEnabled = true;
    expect(_advice(war)?.message, isNot(isA<GuideLeviathanReturn>()));
  });

  test('says nothing with the tutorial off', () {
    expect(_advice(_strikeTurn(tutorial: false)), isNull);
  });
}
