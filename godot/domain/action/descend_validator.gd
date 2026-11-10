class_name DescendValidator
extends RefCounted
## lib/domain/action/descend_validator.dart: whether units may go down
## through a post of `from_level`: a post the player holds, its building
## (the descent module under a Faille, the capsule under a Cheminée) built
## and not degraded, and units enough.


static func validate(
	game: Game, player: Player, transition_x: int, transition_y: int,
	from_level: int, selected_units: Dictionary[UnitType.Value, int],
) -> DescendResult:
	var map: GameMap = game.levels.get(from_level)
	if map == null:
		return DescendResult.failure(ActionFailure.Value.MAP_NOT_GENERATED)
	var cell := map.cell_at(transition_x, transition_y)
	if cell.content != CellContentType.Value.TRANSITION_BASE:
		return DescendResult.failure(ActionFailure.Value.NO_TRANSITION_BASE_HERE)
	var base := cell.transition_base
	if base == null or base.captured_by != player.id:
		return DescendResult.failure(ActionFailure.Value.BASE_NOT_CAPTURED)
	var error := _validate_building(player, base.type)
	if error != null:
		return error
	return _validate_units(player, from_level, selected_units)


static func _validate_building(player: Player, type: TransitionBaseType.Value) -> DescendResult:
	var required := (
		BuildingType.Value.DESCENT_MODULE if type == TransitionBaseType.Value.FAILLE
		else BuildingType.Value.PRESSURE_CAPSULE
	)
	if Building.level_in(player.buildings, required) <= 0:
		return DescendResult.failure(ActionFailure.Value.REQUIRED_BUILDING_MISSING)
	if player.is_degraded(required):
		return DescendResult.failure(ActionFailure.Value.REQUIRED_BUILDING_DEGRADED)
	return null


static func _validate_units(
	player: Player, from_level: int, selected_units: Dictionary[UnitType.Value, int]
) -> DescendResult:
	var total := 0
	for type: UnitType.Value in selected_units:
		var count: int = selected_units[type]
		if count <= 0:
			continue
		if count > Unit.count_in(player.units_on_level(from_level), type):
			return DescendResult.failure(ActionFailure.Value.NOT_ENOUGH_UNITS)
		total += count
	if total <= 0:
		return DescendResult.failure(ActionFailure.Value.NO_UNIT_SELECTED)
	return DescendResult.success(0, {})
