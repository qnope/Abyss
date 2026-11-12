class_name ModelNames
extends RefCounted
## What assets/models/ holds, by name: the root nodes of each model, the ones
## that paint an atlas, the monsters and the base island's pads.

## The root nodes of each model, under the scene's own root.
const ROOTS := {
	"abyss_admiral": ["Rig", "AnimationPlayer"],
	"barracks": ["Barracks"],
	"base_island": ["Island", "Pads"],
	"base_rampart": ["Tier1", "Tier2", "Tier3"],
	"coral_citadel": ["CoralCitadel"],
	"descent_module": ["Tier1", "Tier2", "Tier3"],
	"dome_breaker": ["Rig", "AnimationPlayer"],
	"guardian": ["Rig", "AnimationPlayer"],
	"harpoonist": ["Rig", "AnimationPlayer"],
	"headquarters": ["Headquarters"],
	"laboratory": ["Laboratory"],
	"map_cheminee": ["Body", "Tint"],
	"map_faction_base": ["Body", "Tint"],
	"map_faille": ["Body", "Tint"],
	"map_home": ["Body"],
	"map_kernel": ["Body", "Tint"],
	"map_lair_easy": ["Body"],
	"map_lair_hard": ["Body"],
	"map_lair_medium": ["Body"],
	"map_passage": ["Body", "Tint"],
	"map_resource_algae": ["Body"],
	"map_resource_coral": ["Body"],
	"map_resource_ore": ["Body"],
	"map_ruins": ["Body"],
	"map_treasure": ["Body"],
	"map_wreck": ["Body"],
	"material_swatches": ["Swatches", "Unit"],
	"pressure_capsule": ["Tier1", "Tier2", "Tier3"],
	"probe_fish": ["Rig", "AnimationPlayer"],
	"saboteur": ["Rig", "AnimationPlayer"],
	"scout": ["Rig", "AnimationPlayer"],
	"solar_panel": ["SolarPanel"],
	"algae_farm": ["AlgaeFarm"],
	"armoured": ["Rig", "AnimationPlayer"],
	"colossus": ["Rig", "AnimationPlayer"],
	"hunter": ["Rig", "AnimationPlayer"],
	"kraken": ["Rig", "AnimationPlayer"],
	"leviathan": ["Rig", "AnimationPlayer"],
	"monster_generic": ["Rig", "AnimationPlayer"],
	"swarm": ["Rig", "AnimationPlayer"],
	"coral_mine": ["CoralMine"],
	"ore_extractor": ["OreExtractor"],
	"volcanic_kernel": ["Tier1", "Tier2", "Tier3"],
}

## The models that paint an atlas (<model>_atlas.png beside the glb).
const TEXTURED: Array[String] = [
	"algae_farm", "barracks", "base_rampart", "coral_citadel", "coral_mine", "descent_module",
	"headquarters", "laboratory", "ore_extractor", "pressure_capsule", "solar_panel", "volcanic_kernel",
	"abyss_admiral", "dome_breaker", "guardian", "harpoonist", "saboteur", "scout",
	"armoured", "colossus", "hunter", "kraken", "leviathan", "monster_generic", "swarm",
	"map_cheminee", "map_faction_base", "map_faille", "map_home", "map_kernel", "map_lair_easy",
	"map_lair_hard", "map_lair_medium", "map_passage", "map_resource_algae", "map_resource_coral",
	"map_resource_ore", "map_ruins", "map_treasure", "map_wreck",
]

## The monsters, each of which plays the four actions the game asks for by name.
const MONSTERS: Array[String] = [
	"armoured", "colossus", "hunter", "kraken", "leviathan", "monster_generic", "swarm",
]


## The island's pads, one per building, where the buildings stand.
const PADS: Array[String] = [
	"AlgaeFarm", "Barracks", "CoralCitadel", "CoralMine", "DescentModule", "Headquarters",
	"Laboratory", "OreExtractor", "PressureCapsule", "SolarPanel", "VolcanicKernel",
]
