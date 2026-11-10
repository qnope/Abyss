class_name MagmaRampart
extends RefCounted
## lib/domain/volcano/magma_rampart.dart: the kernel fights beside its
## garrison: a wall of magma that grows with the kernel's level. Unlike the
## Citadel rampart it does not draw the attacks, but it strikes back.

const TYPE_KEY := "magmaRampart"
const HP_PER_LEVEL := 40
const BASE_ATK := 4
const BASE_DEF := 3


static func hp_for_level(level: int) -> int:
	return 0 if level <= 0 else HP_PER_LEVEL * level


static func atk_for_level(level: int) -> int:
	return 0 if level <= 0 else BASE_ATK + 2 * level


static func def_for_level(level: int) -> int:
	return 0 if level <= 0 else BASE_DEF + level


## Rampart combatant of a kernel at `level`, or null at level 0.
static func combatant_for(level: int) -> Combatant:
	if level <= 0:
		return null
	return Combatant.new(
		CombatSide.Value.PLAYER, TYPE_KEY, hp_for_level(level), atk_for_level(level), def_for_level(level)
	)
