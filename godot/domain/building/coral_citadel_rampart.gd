class_name CoralCitadelRampart
extends RefCounted
## lib/domain/building/coral_citadel_rampart.dart: the rampart the Coral
## Citadel raises when the base is raided.
##
## It fights on the defenders' side and draws every monster attack while it
## stands. With no ATK it only scratches (1 damage, like any ATK 0 unit).
## Each Citadel level adds HP_PER_LEVEL PV and one point of DEF on top of
## BASE_DEF.

const TYPE_KEY := CombatRole.RAMPART_KEY
const HP_PER_LEVEL := 40
const BASE_DEF := 4


static func hp_for_level(level: int) -> int:
	return 0 if level <= 0 else HP_PER_LEVEL * level


static func def_for_level(level: int) -> int:
	return 0 if level <= 0 else BASE_DEF + level


static func level_of(buildings: Dictionary[BuildingType.Value, Building]) -> int:
	return Building.level_in(buildings, BuildingType.Value.CORAL_CITADEL)


## Rampart combatant for a Citadel at `level`, or null when unbuilt. A
## `degraded` Citadel has half the PV and half the DEF.
static func combatant_for(level: int, degraded := false) -> Combatant:
	if level <= 0:
		return null
	return Combatant.new(
		CombatSide.Value.PLAYER,
		TYPE_KEY,
		BuildingDegradation.half(hp_for_level(level), degraded),
		0,
		BuildingDegradation.half(def_for_level(level), degraded),
	)


## The rampart of a base's `buildings`, halved when the Citadel is degraded;
## null when unbuilt.
static func combatant_of(buildings: Dictionary[BuildingType.Value, Building]) -> Combatant:
	return combatant_for(
		level_of(buildings),
		BuildingDegradation.is_degraded(buildings, BuildingType.Value.CORAL_CITADEL),
	)
