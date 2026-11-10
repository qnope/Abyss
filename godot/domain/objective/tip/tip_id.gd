class_name TipId
extends RefCounted
## lib/domain/objective/tip/tip_id.dart: every « première fois » tip card,
## in the order they are offered when several situations call for one at
## once: the Archives, last, come after the cards that explain the game.

enum Value {
	NOISE_GAUGE,
	WORKSITES,
	TECH_CHOICE,
	RAID_ANNOUNCED,
	RAID_REPORT,
	LAST_CHANCE,
	LAIR,
	MONSTER_FAMILIES,
	VOLCANO_WAVE,
	CHEST_AND_RUINS,
	TRANSITION_BASE,
	DESCENT,
	EVENTS,
	WARM_CURRENT,
	WRECK,
	PREDATORS,
	STORM,
	SURVIVORS,
	CARAVAN,
	COLD_CURRENT,
	FACTION_ATTACK,
	ADMIRAL,
	POST_DEFENCE,
	KERNEL_GARRISON,
	POST_LOST,
	ABYSS_LISTENS,
	RIVAL_COLONIES,
	ANCIENTS,
	FORGE_TOWERS,
	AWAKENING,
}
