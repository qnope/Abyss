class_name UpgradeReadiness
extends RefCounted
## lib/domain/building/upgrade_readiness.dart: whether a building can go up
## a level right now, by the rules of the upgrade action: what `check` says
## of its level, costs and prerequisites, and whether a worksite is still
## `site_free` this turn.

var check: UpgradeCheck
## Whether a building site is still free this turn.
var site_free: bool


func _init(check_: UpgradeCheck, site_free_: bool) -> void:
	check = check_
	site_free = site_free_


## `UpgradeReadiness.of`: the readiness of the building of `type` among
## `buildings`, paid from `resources`, the worksite of the turn being
## `worksite`. `captured_base_types` is a set.
static func of(
	type: BuildingType.Value,
	buildings: Dictionary[BuildingType.Value, Building],
	resources: Dictionary[ResourceType.Value, GameResource],
	worksite: Worksite,
	captured_base_types: Dictionary[TransitionBaseType.Value, bool] = {},
	is_volcanic_kernel_captured := false,
	discount_percent := 0,
) -> UpgradeReadiness:
	var calculator := BuildingCostCalculator.new(discount_percent)
	var hq_level := Building.level_in(buildings, BuildingType.Value.HEADQUARTERS)
	return UpgradeReadiness.new(
		calculator.check_upgrade(
			type,
			Building.level_in(buildings, type),
			resources,
			buildings,
			captured_base_types,
			is_volcanic_kernel_captured,
		),
		worksite.free_build_sites(hq_level) > 0,
	)


## Whether the building can go up a level now: a free worksite, the costs
## paid, every requirement met and its maximum not reached.
func is_ready() -> bool:
	return site_free and check.can_upgrade


## Whether something else than resources or a worksite holds it back: a
## building to raise first, a base or the volcanic core to capture.
func is_locked() -> bool:
	return (
		not check.missing_prerequisites.is_empty()
		or check.missing_captured_base != null
		or check.missing_captured_kernel
	)
