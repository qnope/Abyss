import 'dart:math';

import '../game/game.dart';
import '../game/player.dart';
import '../raid/announced_attack.dart';
import '../replay/seeded_random.dart';
import '../unit/unit_type.dart';
import 'action.dart';
import 'action_failure.dart';
import 'action_result.dart';
import 'action_type.dart';
import 'announce_attack_validator.dart';

/// A faction announces an attack on the human base, to be fought at the
/// end of the turn [leadTurns] turns from now, with [selectedUnits].
///
/// The army stays on the base of the faction, which still defends with it,
/// until the fight: like in any attack on a base, it only leaves for the
/// fight and comes back at once. `AnnouncedAttackResolver` fights it; the
/// dice of the fight are [random]'s seed, so a replay fights the same
/// battle.
class AnnounceAttackAction extends Action {
  /// Turns between the announcement and the fight, as for a monster raid.
  static const int leadTurns = 2;

  final Map<UnitType, int> selectedUnits;
  final Random? random;

  AnnounceAttackAction({required this.selectedUnits, this.random});

  @override
  ActionType get type => ActionType.announceAttack;

  @override
  String get description => 'Annonce une attaque sur la base du joueur';

  @override
  ActionResult validate(Game game, Player player) {
    final ActionFailure? failure = AnnounceAttackValidator.check(
      game,
      player,
      selectedUnits,
      arrivalTurn: game.turn + leadTurns,
    );
    return failure == null
        ? const ActionResult.success()
        : ActionResult.failure(failure);
  }

  @override
  ActionResult execute(Game game, Player player) {
    final ActionResult validation = validate(game, player);
    if (!validation.isSuccess) return validation;
    final Random dice = random ?? Random();
    game.humanPlayer.raidState.attacks.add(
      AnnouncedAttack(
        attackerId: player.id,
        units: Map<UnitType, int>.from(selectedUnits)
          ..removeWhere((_, int n) => n <= 0),
        arrivalTurn: game.turn + leadTurns,
        seed: dice is SeededRandom ? dice.seed : dice.nextInt(0x7FFFFFFF),
      ),
    );
    return const ActionResult.success();
  }
}
