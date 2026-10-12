import 'package:abyss/domain/fight/assault/assault_plan.dart';
import 'package:abyss/domain/fight/assault/assault_target.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/objective/guide/guide_advice.dart';
import 'package:abyss/domain/objective/guide/guide_message.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/guide_campaign_helpers.dart';
import '../../../helpers/guide_helpers.dart';
import '../../../helpers/objective_helpers.dart';

void main() {
  const cheminee = AssaultTarget.cheminee;
  const kernel = AssaultTarget.kernel;
  const chimney = TransitionBaseType.cheminee;

  group('the deeper assaults need the admiral down there', () {
    test('an admiral on level 1 goes down by the Faille', () {
      final game = campaignGame(ObjectiveId.takeCheminee);
      setUnits(game.humanPlayer, UnitType.abyssAdmiral, 1);
      setUnits(game.humanPlayer, UnitType.harpoonist, 3, level: 2);
      placePost(game, 1, 7, 5, held: true);
      expect(
        adviceOf(game),
        GuideAdvice(
          const GuideAdmiralToSend(cheminee, 2),
          GuideTarget.cell(1, GridPosition(x: 7, y: 5)),
        ),
      );
    });

    test('with no post held to go down by, the map', () {
      final game = campaignGame(ObjectiveId.takeCheminee);
      setUnits(game.humanPlayer, UnitType.abyssAdmiral, 1);
      expect(adviceOf(game)!.target, const GuideTarget.map());
    });

    test('an admiral already deeper does not count', () {
      final game = campaignGame(ObjectiveId.takeCheminee);
      setUnits(game.humanPlayer, UnitType.abyssAdmiral, 1, level: 3);
      expect(adviceOf(game)!.message, isA<GuideAdmiralNeedsBarracks>());
    });

    test('explains a fallen admiral on the Cheminée', () {
      final game = campaignGame(ObjectiveId.takeCheminee);
      setUnits(game.humanPlayer, UnitType.abyssAdmiral, 1, level: 2);
      recordAdmiralFell(game, 'cheminee:1', turn: game.turn);
      expect(adviceOf(game)!.message, const GuideAdmiralFell(cheminee));
    });

    test('the Cheminée in sight on level 2', () {
      final game = campaignGame(ObjectiveId.takeCheminee);
      setUnits(game.humanPlayer, UnitType.abyssAdmiral, 1, level: 2);
      placePost(game, 2, 3, 3, type: chimney);
      final plan = AssaultPlan.of(
        player: game.humanPlayer,
        level: 2,
        target: cheminee,
        army: {UnitType.abyssAdmiral: 1},
      );
      expect(
        adviceOf(game),
        GuideAdvice(
          GuidePostAssault(cheminee, harpoonists: plan.suggestedHarpoonists),
          GuideTarget.cell(2, GridPosition(x: 3, y: 3)),
        ),
      );
    });

    test('an admiral on level 2 goes down by the Cheminée', () {
      final game = campaignGame(ObjectiveId.takeKernel);
      setUnits(game.humanPlayer, UnitType.abyssAdmiral, 1, level: 2);
      setUnits(game.humanPlayer, UnitType.harpoonist, 3, level: 3);
      placePost(game, 2, 3, 3, type: chimney, held: true);
      expect(
        adviceOf(game),
        GuideAdvice(
          const GuideAdmiralToSend(kernel, 3),
          GuideTarget.cell(2, GridPosition(x: 3, y: 3)),
        ),
      );
    });

    test('the kernel in sight on level 3', () {
      final game = campaignGame(ObjectiveId.takeKernel);
      setUnits(game.humanPlayer, UnitType.abyssAdmiral, 1, level: 3);
      placeKernel(game, 4, 4);
      final advice = adviceOf(game)!;
      expect(advice.message, isA<GuidePostAssault>());
      expect((advice.message as GuidePostAssault).target, kernel);
      expect(advice.target, GuideTarget.cell(3, GridPosition(x: 4, y: 4)));
    });
  });
}
