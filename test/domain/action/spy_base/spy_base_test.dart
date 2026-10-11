import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/action/spy_base_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/base_intel.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/base_attack_helper.dart';
import '../../../helpers/two_player_game.dart';

TwoPlayerGame _scene({bool scout = true}) {
  final two = assaultGame();
  station(two.human, scout ? {UnitType.scout: 2} : {});
  station(
    two.rival,
    {UnitType.guardian: 7, UnitType.harpoonist: 12},
  );
  setLevel(two.rival, BuildingType.coralCitadel, 3);
  two.rival.resources[ResourceType.coral]!.amount = 640;
  return two;
}

SpyBaseAction _spy(TwoPlayerGame two) =>
    SpyBaseAction(targetPlayerId: two.rival.id);

void main() {
  group('spying a base', () {
    test('writes down its headquarters, rampart, army and stocks', () {
      final two = _scene();
      two.game.turn = 12;

      final result = _spy(two).execute(two.game, two.human);

      expect(result.isSuccess, isTrue);
      final BaseIntel intel = two.human.intel[two.rival.id]!;
      expect(intel.turn, 12);
      expect(intel.headquartersLevel, 5);
      expect(intel.rampartLevel, 3);
      expect(intel.army, {UnitType.guardian: 7, UnitType.harpoonist: 12});
      expect(intel.stocks[ResourceType.coral], 640);
    });

    test('costs the scout that went', () {
      final two = _scene();

      _spy(two).execute(two.game, two.human);

      expect(standing(two.human, UnitType.scout), 1);
    });

    test('leaves the target as it was', () {
      final two = _scene();

      _spy(two).execute(two.game, two.human);

      expect(standing(two.rival, UnitType.guardian), 7);
      expect(two.rival.intel, isEmpty);
      expect(two.rival.historyEntries, isEmpty);
    });

    test('is a snapshot: the base can change afterwards', () {
      final two = _scene();
      _spy(two).execute(two.game, two.human);

      station(two.rival, {});

      expect(two.human.intel[two.rival.id]!.army[UnitType.guardian], 7);
    });

    test('holds for five turns, then goes stale', () {
      final two = _scene();
      two.game.turn = 12;
      _spy(two).execute(two.game, two.human);
      final BaseIntel intel = two.human.intel[two.rival.id]!;

      expect(intel.isFresh(12), isTrue);
      expect(intel.isFresh(17), isTrue);
      expect(intel.isFresh(18), isFalse);
      expect(intel.turnsLeft(14), 3);
    });

    test('a second spy renews the report', () {
      final two = _scene();
      two.game.turn = 12;
      _spy(two).execute(two.game, two.human);
      two.game.turn = 16;
      station(two.rival, {UnitType.guardian: 2});
      station(two.human, {UnitType.scout: 1});

      _spy(two).execute(two.game, two.human);

      final BaseIntel intel = two.human.intel[two.rival.id]!;
      expect(intel.turn, 16);
      expect(intel.army, {UnitType.guardian: 2});
    });
  });

  group('the refusals', () {
    ActionFailure? why(TwoPlayerGame two) =>
        _spy(two).validate(two.game, two.human).reason;

    test('a scout is needed', () {
      expect(why(_scene(scout: false)), ActionFailure.notEnoughUnits);
    });

    test('the base must have been seen', () {
      final two = assaultGame(revealed: false);
      station(two.human, {UnitType.scout: 1});

      expect(why(two), ActionFailure.baseNotRevealed);
    });

    test('one cannot spy on oneself', () {
      final two = _scene();

      expect(
        SpyBaseAction(targetPlayerId: two.human.id)
            .validate(two.game, two.human)
            .reason,
        ActionFailure.cannotAttackSelf,
      );
    });

    test('an unknown player cannot be spied', () {
      final two = _scene();

      expect(
        SpyBaseAction(targetPlayerId: 'nobody')
            .validate(two.game, two.human)
            .reason,
        ActionFailure.noSuchPlayer,
      );
    });

    test('a fallen base is not worth a scout', () {
      final two = _scene();
      two.rival.savedFallen = true;

      expect(why(two), ActionFailure.playerFallen);
    });
  });

  test('the human can be named as a target for a script', () {
    final two = _scene();
    station(two.rival, {UnitType.scout: 1});
    two.rival.addRevealedCell(1, GridPosition(x: two.human.baseX, y: two.human.baseY));

    final result = SpyBaseAction(
      targetPlayerId: SpyBaseAction.human,
    ).execute(two.game, two.rival);

    expect(result.isSuccess, isTrue);
    expect(two.rival.intel[two.human.id], isNotNull);
  });
}
