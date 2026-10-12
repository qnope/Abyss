import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/objective/guide/guide_advice.dart';
import 'package:abyss/domain/objective/guide/guide_message.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/worksite/worksite_rules.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/guide_campaign_helpers.dart';
import '../../../helpers/guide_helpers.dart';
import '../../../helpers/objective_helpers.dart';

void main() {
  const hq = GuideTarget.building(BuildingType.headquarters);

  test('the reef and the awakening stay silent', () {
    expect(adviceOf(campaignGame(ObjectiveId.takeLair)), isNull);
    expect(adviceOf(campaignGame(ObjectiveId.kernelLevel5)), isNull);
  });

  test('a met objective asks to end the turn', () {
    final game = campaignGame(ObjectiveId.hqLevel8);
    setBuilding(game.humanPlayer, BuildingType.headquarters, 8);
    expect(
      adviceOf(game),
      const GuideAdvice(GuideGoalMet(), GuideTarget.endTurn()),
    );
  });

  group('a passage building', () {
    test('first asks for the headquarters it needs', () {
      expect(
        adviceOf(campaignGame(ObjectiveId.descentModule)),
        const GuideAdvice(
          GuidePassageNeedsHq(BuildingType.descentModule, 5),
          hq,
        ),
      );
      expect(
        adviceOf(campaignGame(ObjectiveId.pressureCapsule)),
        const GuideAdvice(
          GuidePassageNeedsHq(BuildingType.pressureCapsule, 8),
          hq,
        ),
      );
    });

    test('then points at its card', () {
      final game = campaignGame(ObjectiveId.descentModule);
      setBuilding(game.humanPlayer, BuildingType.headquarters, 5);
      expect(
        adviceOf(game),
        const GuideAdvice(
          GuideLesson(ObjectiveId.descentModule),
          GuideTarget.building(BuildingType.descentModule),
        ),
      );
    });

    test('unless the worksite is taken', () {
      final game = campaignGame(ObjectiveId.pressureCapsule);
      setBuilding(game.humanPlayer, BuildingType.headquarters, 8);
      game.humanPlayer.worksite.upgrades = WorksiteRules.buildSites(8);
      expect(
        adviceOf(game),
        const GuideAdvice(GuideWorksiteTaken(), GuideTarget.endTurn()),
      );
    });
  });

  group('a descent points at the post to go down by', () {
    test('the Faille for level 2', () {
      final game = campaignGame(ObjectiveId.descendLevel2);
      setBuilding(game.humanPlayer, BuildingType.descentModule, 1);
      placePost(game, 1, 7, 5, held: true);
      expect(
        adviceOf(game),
        GuideAdvice(
          const GuideLesson(ObjectiveId.descendLevel2),
          GuideTarget.cell(1, GridPosition(x: 7, y: 5)),
        ),
      );
    });

    test('the Cheminée for level 3', () {
      final game = campaignGame(ObjectiveId.descendLevel3);
      placePost(game, 2, 3, 3, type: TransitionBaseType.cheminee, held: true);
      expect(
        adviceOf(game)!.target,
        GuideTarget.cell(2, GridPosition(x: 3, y: 3)),
      );
    });

    test('the map without a post held', () {
      expect(
        adviceOf(campaignGame(ObjectiveId.descendLevel2))!.target,
        const GuideTarget.map(),
      );
    });
  });

  test('the headquarters and the kernel teach their lesson', () {
    for (final id in [ObjectiveId.hqLevel8, ObjectiveId.hqLevel10]) {
      expect(adviceOf(campaignGame(id)), GuideAdvice(GuideLesson(id), hq));
    }
    expect(
      adviceOf(campaignGame(ObjectiveId.kernelLevel1)),
      const GuideAdvice(
        GuideLesson(ObjectiveId.kernelLevel1),
        GuideTarget.building(BuildingType.volcanicKernel),
      ),
    );
  });
}
