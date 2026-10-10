import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/exploration_order.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/objective/guide/guide_message.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/guide_helpers.dart';
import '../../../helpers/objective_helpers.dart';

void main() {
  test('a goal met asks to end the turn to validate it', () {
    final game = guideGame(ObjectiveId.hqLevel1);
    setBuilding(game.humanPlayer, BuildingType.headquarters, 1);

    final advice = adviceOf(game)!;

    expect(advice.message, const GuideGoalMet());
    expect(advice.target, const GuideTarget.endTurn());
  });

  test('a taken worksite asks to end the turn', () {
    final game = guideGame(ObjectiveId.mines);
    setBuilding(game.humanPlayer, BuildingType.coralMine, 1);
    game.humanPlayer.worksite.upgrades = 1;

    final advice = adviceOf(game)!;

    expect(advice.message, const GuideWorksiteTaken());
    expect(advice.target, const GuideTarget.endTurn());
  });

  test('scouts already recruited this turn ask to end the turn', () {
    final game = guideGame(ObjectiveId.barracksAndScouts);
    final player = game.humanPlayer;
    setBuilding(player, BuildingType.barracks, 1);
    setUnits(player, UnitType.scout, 1);
    player.recruitedUnitTypes.add(UnitType.scout);

    final advice = adviceOf(game)!;

    expect(advice.message, const GuideAlreadyRecruited());
    expect(advice.target, const GuideTarget.endTurn());
  });

  group('exploring', () {
    test('a scout on its way asks to end the turn', () {
      final game = guideGame(ObjectiveId.explore);
      game.humanPlayer.pendingExplorations.add(
        ExplorationOrder(target: GridPosition(x: 8, y: 5)),
      );

      final advice = adviceOf(game)!;

      expect(advice.message, const GuideExploring());
      expect(advice.target, const GuideTarget.endTurn());
    });

    test('a storm makes the objective wait', () {
      final game = guideGame(ObjectiveId.explore)..turn = 7;
      game.humanPlayer.eventState.activate(RandomEventType.storm, untilTurn: 8);

      final advice = adviceOf(game)!;

      expect(advice.message, const GuideStorm(8));
      expect(advice.target, const GuideTarget.endTurn());
    });

    test('a storm does not change another objective', () {
      final game = guideGame(ObjectiveId.solarPanel)..turn = 7;
      game.humanPlayer.eventState.activate(RandomEventType.storm, untilTurn: 8);

      expect(
        adviceOf(game)!.message,
        const GuideLesson(ObjectiveId.solarPanel),
      );
    });
  });

  group('a wreck on the map', () {
    void sinkWreck(Game game) =>
        game.humanPlayer.eventState
          ..wreckPosition = GridPosition(x: 8, y: 5)
          ..wreckUntilTurn = 9;

    test('before the barracks, keeps pointing at the objective', () {
      final game = guideGame(ObjectiveId.solarPanel);
      sinkWreck(game);

      final advice = adviceOf(game)!;

      expect(advice.message, const GuideWreck(9, hasBarracks: false));
      expect(
        advice.target,
        const GuideTarget.building(BuildingType.solarPanel),
      );
    });

    test('with the barracks but no scout, points at the scouts', () {
      final game = guideGame(ObjectiveId.barracksAndScouts);
      setBuilding(game.humanPlayer, BuildingType.barracks, 1);
      sinkWreck(game);

      final advice = adviceOf(game)!;

      expect(advice.message, const GuideWreck(9, hasBarracks: true));
      expect(advice.target, const GuideTarget.unit(UnitType.scout));
    });

    test('says nothing more once a scout can reach it', () {
      final game = guideGame(ObjectiveId.laboratoryAndResearch);
      setBuilding(game.humanPlayer, BuildingType.barracks, 1);
      setUnits(game.humanPlayer, UnitType.scout, 2);
      sinkWreck(game);

      expect(adviceOf(game)!.message, isNot(isA<GuideWreck>()));
    });
  });
}
