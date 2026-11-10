class_name BaseDamage
extends RefCounted
## lib/domain/action/base_damage.dart: what a won attack did to a base, and
## what it brought the attacker.

## Levels of the Citadel (the rampart) and of the headquarters.
var rampart_before: int
var rampart_after: int
var headquarters_before: int
var headquarters_after: int
## Taken from the stocks of the defender, pearls aside.
var pillaged: Dictionary[ResourceType.Value, int]
## Part of `pillaged` the attacker's storage could hold.
var loot: Dictionary[ResourceType.Value, int]


func _init(
	rampart_before_: int,
	rampart_after_: int,
	headquarters_before_: int,
	headquarters_after_: int,
	pillaged_: Dictionary[ResourceType.Value, int] = {},
	loot_: Dictionary[ResourceType.Value, int] = {},
) -> void:
	rampart_before = rampart_before_
	rampart_after = rampart_after_
	headquarters_before = headquarters_before_
	headquarters_after = headquarters_after_
	pillaged = pillaged_
	loot = loot_


## `BaseDamage.none`: nothing broken, nothing taken: the state of `target`
## as it stands.
static func none(target: Player) -> BaseDamage:
	var rampart := CoralCitadelRampart.level_of(target.buildings)
	var hq := target.buildings[BuildingType.Value.HEADQUARTERS].level
	return BaseDamage.new(rampart, rampart, hq, hq)


## `BaseDamage.kernel`: a kernel brought from level `before` to `after`: the
## kernel levels travel in the rampart fields, the headquarters are not
## touched.
static func kernel(before: int, after: int) -> BaseDamage:
	return BaseDamage.new(before, after, 0, 0)
