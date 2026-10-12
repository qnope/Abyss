import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/fight/assault/assault_plan.dart';
import 'package:abyss/domain/fight/assault/assault_target.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/objective/guide/guide_advice.dart';
import 'package:abyss/domain/objective/guide/guide_message.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/guide_campaign_helpers.dart';
import '../../../helpers/guide_helpers.dart';
import '../../../helpers/objective_helpers.dart';

/// The harpoonists the plan advises with the admirals and guardians of
/// [game]'s human player on [level].
int? _advised(Game game, AssaultTarget target, int level) {
  final units = game.humanPlayer.unitsOnLevel(level);
  return AssaultPlan.of(
    player: game.humanPlayer,
    level: level,
    target: target,
    army: {
      UnitType.abyssAdmiral: units[UnitType.abyssAdmiral]?.count ?? 0,
      UnitType.guardian: units[UnitType.guardian]?.count ?? 0,
    },
  ).suggestedHarpoonists;
}

void main() {
  const faille = AssaultTarget.faille;

  test('the guide stays silent on the campaign when the tutorial is off', () {
    expect(
      adviceOf(campaignGame(ObjectiveId.takeFaille, tutorial: false)),
      isNull,
    );
  });

  group('taking a Faille', () {
    test('asks for the barracks the admiral needs', () {
      expect(
        adviceOf(campaignGame(ObjectiveId.takeFaille)),
        const GuideAdvice(
          GuideAdmiralNeedsBarracks(faille, 2),
          GuideTarget.building(BuildingType.barracks),
        ),
      );
    });

    test('then asks to recruit the admiral', () {
      final game = campaignGame(ObjectiveId.takeFaille);
      setBuilding(game.humanPlayer, BuildingType.barracks, 2);
      expect(
        adviceOf(game),
        const GuideAdvice(
          GuideAdmiralToRecruit(faille),
          GuideTarget.unit(UnitType.abyssAdmiral),
        ),
      );
    });

    test('then sends exploring while no Faille is in sight', () {
      final game = campaignGame(ObjectiveId.takeFaille);
      setUnits(game.humanPlayer, UnitType.abyssAdmiral, 1);
      placePost(game, 1, 0, 0, hidden: true);
      expect(
        adviceOf(game),
        const GuideAdvice(GuidePostToFind(faille), GuideTarget.map()),
      );
    });

    test('then points at the nearest Faille in sight, with the army', () {
      final game = campaignGame(ObjectiveId.takeFaille);
      setUnits(game.humanPlayer, UnitType.abyssAdmiral, 1);
      setUnits(game.humanPlayer, UnitType.guardian, 2);
      game.humanPlayer.revealedCellsPerLevel[1]!.clear();
      placePost(game, 1, 9, 9);
      placePost(game, 1, 7, 5);
      placePost(game, 1, 5, 6, hidden: true);
      final int? harpoonists = _advised(game, faille, 1);
      expect(harpoonists, isNotNull);
      expect(
        adviceOf(game),
        GuideAdvice(
          GuidePostAssault(faille, harpoonists: harpoonists),
          GuideTarget.cell(1, GridPosition(x: 7, y: 5)),
        ),
      );
    });

    test('explains a victory where the admiral fell, this turn only', () {
      final game = campaignGame(ObjectiveId.takeFaille);
      setUnits(game.humanPlayer, UnitType.abyssAdmiral, 1);
      placePost(game, 1, 7, 5);
      recordAdmiralFell(game, 'faille:0', turn: game.turn);
      final advice = adviceOf(game)!;
      expect(advice.message, const GuideAdmiralFell(faille));
      expect(advice.target, GuideTarget.cell(1, GridPosition(x: 7, y: 5)));

      game.turn++;
      expect(adviceOf(game)!.message, isA<GuidePostAssault>());
    });

    test('ignores a fallen admiral on another target', () {
      final game = campaignGame(ObjectiveId.takeFaille);
      recordAdmiralFell(game, 'volcanicKernel', turn: game.turn);
      recordAdmiralFell(game, 'cheminee:0', turn: game.turn);
      recordAdmiralFell(game, 'Base A', turn: game.turn);
      expect(adviceOf(game)!.message, isA<GuideAdmiralNeedsBarracks>());
    });

    test('breaks a tie of distance by row, then by column', () {
      final game = campaignGame(ObjectiveId.takeFaille);
      setUnits(game.humanPlayer, UnitType.abyssAdmiral, 1);
      placePost(game, 1, 5, 7);
      placePost(game, 1, 7, 5);
      placePost(game, 1, 3, 5);
      expect(
        adviceOf(game)!.target,
        GuideTarget.cell(1, GridPosition(x: 3, y: 5)),
      );
      placePost(game, 1, 5, 3);
      expect(
        adviceOf(game)!.target,
        GuideTarget.cell(1, GridPosition(x: 5, y: 3)),
      );
    });
  });
}
