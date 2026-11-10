class_name AnnounceAttackAction
extends Action
## lib/domain/action/announce_attack_action.dart: a faction attacks the
## human base with `selected_units`: the attack is fought at the end of the
## turn it is decided, without any warning, like the attacks of the human on
## the others.
##
## The army stays on the base of the faction, which still defends with it,
## until the fight: like in any attack on a base, it only leaves for the
## fight and comes back at once. `AnnouncedAttackResolver` fights it; the
## dice of the fight are `random`'s seed, so a replay fights the same
## battle.

## Turns between the decision and the fight: none, the human is not warned.
const LEAD_TURNS := 0

var selected_units: Dictionary[UnitType.Value, int]
## Null where Dart passes none: the seed of the fight is then drawn.
var random: DartRandom


func _init(selected_units_: Dictionary[UnitType.Value, int], random_: DartRandom = null) -> void:
	selected_units = selected_units_
	random = random_


func type() -> ActionType.Value:
	return ActionType.Value.ANNOUNCE_ATTACK


func description() -> String:
	return "Annonce une attaque sur la base du joueur"


func validate(game: Game, player: Player) -> ActionResult:
	var failure: Variant = AnnounceAttackValidator.check(game, player, selected_units, game.turn + LEAD_TURNS)
	if failure == null:
		return ActionResult.success()
	var reason: ActionFailure.Value = failure
	return ActionResult.failure(reason)


## Every DartRandom remembers its seed, as a `SeededRandom` does: the
## fight takes the seed of `random`, and draws one when there is none
## (`Random()` in Dart, which is no `SeededRandom`).
func execute(game: Game, player: Player) -> ActionResult:
	var validation := validate(game, player)
	if not validation.is_success:
		return validation
	var fight_seed := random.initial_seed if random != null else DartRandom.unseeded().next_int(0x7FFFFFFF)
	var units: Dictionary[UnitType.Value, int] = {}
	for type_: UnitType.Value in selected_units:
		if selected_units[type_] > 0:
			units[type_] = selected_units[type_]
	game.human_player().raid_state.attacks.append(
		AnnouncedAttack.new(player.id, units, game.turn + LEAD_TURNS, fight_seed)
	)
	return ActionResult.success()
