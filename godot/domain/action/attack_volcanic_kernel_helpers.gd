class_name AttackVolcanicKernelHelpers
extends RefCounted
## lib/domain/action/attack_volcanic_kernel_helpers.dart: the army of an
## assault on the volcanic kernel, checked against the stock.


## The failure that keeps `selected_units` of `level` home: no Abyss Admiral
## among them, or more of a type than `player` holds; null when they may go.
static func validate_units(
	player: Player, level: int, selected_units: Dictionary[UnitType.Value, int]
) -> AttackVolcanicKernelResult:
	if selected_units.get(UnitType.Value.ABYSS_ADMIRAL, 0) <= 0:
		return AttackVolcanicKernelResult.failure(ActionFailure.Value.ADMIRAL_REQUIRED)
	var stock := player.units_on_level(level)
	for type: UnitType.Value in selected_units:
		var count: int = selected_units[type]
		if count <= 0:
			continue
		if count > Unit.count_in(stock, type):
			return AttackVolcanicKernelResult.failure(ActionFailure.Value.NOT_ENOUGH_UNITS)
	return null
