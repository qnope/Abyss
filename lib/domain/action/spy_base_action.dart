import '../building/building_type.dart';
import '../building/coral_citadel_rampart.dart';
import '../faction/base_intel.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../map/grid_position.dart';
import '../raid/raid_battle.dart';
import '../resource/resource.dart';
import '../resource/resource_type.dart';
import '../unit/unit_type.dart';
import 'action.dart';
import 'action_failure.dart';
import 'action_result.dart';
import 'action_type.dart';

/// Sends a Scout to the base of another player, who has to be one the
/// spy has seen. The Scout does not come back, and brings a [BaseIntel]
/// of the base as it stands now: headquarters, rampart, army, stocks.
///
/// The target is never told. Spying again renews the report.
class SpyBaseAction extends Action {
  /// Names the human player as a target, for a script or a replay that
  /// cannot know the id of the player's game.
  static const String human = 'human';

  final String targetPlayerId;

  SpyBaseAction({required this.targetPlayerId});

  String _targetId(Game game) =>
      targetPlayerId == human ? game.humanPlayerId : targetPlayerId;

  @override
  ActionType get type => ActionType.spyBase;

  @override
  String get description => 'Espionne la base $targetPlayerId';

  /// Why [player] may not spy on [targetId] now, `null` if it may; the
  /// part of [validate] a screen can tell before the Scout leaves.
  static ActionFailure? refusal(Game game, Player player, String targetId) {
    final Player? target = game.players[targetId];
    if (target == null) return ActionFailure.noSuchPlayer;
    if (target.id == player.id) return ActionFailure.cannotAttackSelf;
    if (target.hasFallen) return ActionFailure.playerFallen;
    final bool seen = player
        .revealedCellsOnLevel(RaidBattle.baseLevel)
        .contains(GridPosition(x: target.baseX, y: target.baseY));
    if (!seen) return ActionFailure.baseNotRevealed;
    final int scouts =
        player.unitsOnLevel(RaidBattle.baseLevel)[UnitType.scout]?.count ?? 0;
    return scouts > 0 ? null : ActionFailure.notEnoughUnits;
  }

  @override
  ActionResult validate(Game game, Player player) {
    final ActionFailure? failure = refusal(game, player, _targetId(game));
    return failure == null
        ? const ActionResult.success()
        : ActionResult.failure(failure);
  }

  @override
  ActionResult execute(Game game, Player player) {
    final ActionResult validation = validate(game, player);
    if (!validation.isSuccess) return validation;
    final Player target = game.players[_targetId(game)]!;
    player.unitsOnLevel(RaidBattle.baseLevel)[UnitType.scout]!.count -= 1;
    player.intel[target.id] = BaseIntel(
      turn: game.turn,
      headquartersLevel: target.buildings[BuildingType.headquarters]!.level,
      rampartLevel: CoralCitadelRampart.levelOf(target.buildings),
      army: RaidBattle.defendersOf(target),
      stocks: <ResourceType, int>{
        for (final MapEntry<ResourceType, Resource> e
            in target.resources.entries)
          e.key: e.value.amount,
      },
    );
    return const ActionResult.success();
  }
}
