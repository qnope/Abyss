class_name AttackTransitionBaseValidator
extends RefCounted
## lib/domain/action/attack_transition_base_validator.dart: the rules that
## say whether a Player may assault the guardians of a Faille or a Cheminée
## nobody holds yet.


## Success when `player` may send `units` of `level` against the post at
## (`x`, `y`); otherwise the failure that says why not.
static func check(
	game: Game, player: Player, level: int, x: int, y: int, units: Dictionary[UnitType.Value, int]
) -> ActionResult:
	var map: GameMap = game.levels.get(level)
	if map == null:
		return AttackTransitionBaseResult.failure(ActionFailure.Value.MAP_NOT_GENERATED)
	var cell := map.cell_at(x, y)
	if cell.content != CellContentType.Value.TRANSITION_BASE:
		return AttackTransitionBaseResult.failure(ActionFailure.Value.NO_TRANSITION_BASE_HERE)
	var base := cell.transition_base
	if base == null:
		return AttackTransitionBaseResult.failure(ActionFailure.Value.BASE_NOT_FOUND)
	if base.is_captured():
		return AttackTransitionBaseResult.failure(ActionFailure.Value.BASE_ALREADY_CAPTURED)
	var unit_err := AttackTransitionBaseHelpers.validate_units(player, level, units)
	if unit_err != null:
		return unit_err
	return ActionResult.success()
