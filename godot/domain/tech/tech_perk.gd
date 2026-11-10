class_name TechPerk
extends RefCounted
## lib/domain/tech/tech_perk.dart: effect of one option of a choice node,
## two per branch level 2 and 4.

enum Value {
	CORAL_BLADES,
	NACRE_SHELL,
	LIVING_RAMPART,
	DEEP_ASSAULT,
	INTENSIVE_FARMING,
	DEEP_DRILLING,
	SEALED_CHESTS,
	THRIFTY_WORKSITES,
	DEEP_SONAR,
	SILENT_SWIM,
	WRECK_RAIDERS,
	SENTINELS,
}

## The perks of a branch: options A then B of level 2, then of level 4.
const _BY_BRANCH: Dictionary[TechBranch.Value, Array] = {
	TechBranch.Value.MILITARY: [
		Value.CORAL_BLADES, Value.NACRE_SHELL, Value.LIVING_RAMPART, Value.DEEP_ASSAULT,
	],
	TechBranch.Value.RESOURCES: [
		Value.INTENSIVE_FARMING, Value.DEEP_DRILLING, Value.SEALED_CHESTS,
		Value.THRIFTY_WORKSITES,
	],
	TechBranch.Value.EXPLORER: [
		Value.DEEP_SONAR, Value.SILENT_SWIM, Value.WRECK_RAIDERS, Value.SENTINELS,
	],
}


## The perk granted by `option` at the choice node of `level` (a Value), or
## null when `level` is a shared tier.
static func of(branch: TechBranch.Value, level: int, option: TechOption.Value) -> Variant:
	if not TechTree.is_choice_level(level):
		return null
	var perks: Array = _BY_BRANCH[branch]
	return perks[TechTree.choice_index(level) * 2 + option]
