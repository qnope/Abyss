class_name VectorRegistry
extends RefCounted
## Where every section of every file of reference/vectors stands: held by a
## test of the port, or waiting for a module of lib/domain to be ported.
## vector_registry_test.gd fails on a section that is in neither state, so a
## new vector file or section cannot be forgotten, and on a test that does
## not read the section it is listed for.
##
## Porting a module: move its sections from "pending: <module>" to the test
## that calls the port with each case.

const PENDING := "pending: "
const _DART := "res://domain/dart/"
const _BUILDING := "res://domain/building/tests/"
const _RESOURCE := "res://domain/resource/tests/"

## file → state → sections. A state is the path of the test that reads the
## sections, or PENDING and the module of lib/domain they wait for.
const FILES: Dictionary[String, Dictionary] = {
	"dart_random": {
		_DART + "dart_random_test.gd": [
			"nextInt", "nextDouble", "nextBool", "mixed", "afterMany", "refused", "seededRandom",
		],
	},
	"dart_shuffle": {_DART + "dart_shuffle_test.gd": ["shuffle", "twice"]},
	"dart_sort": {_DART + "dart_sort_test.gd": ["sort", "natural"]},
	"dart_math": {
		_DART + "dart_math_test.gd": [
			"intDivision", "divisionByZero", "quotient", "rounding", "notFinite", "pow",
		],
		_DART + "dart_bits_test.gd": ["bits"],
		_DART + "dart_native_test.gd": ["abs"],
		_DART + "dart_num_test.gd": ["clamp", "minMax"],
		_DART + "dart_native_float_test.gd": ["literals"],
	},
	"buildings": {
		_RESOURCE + "exponential_cost_test.gd": ["exponentialCost"],
		_BUILDING + "building_cost_vectors_test.gd": ["upgradeCost", "limits"],
		_BUILDING + "building_degradation_test.gd": ["degradation"],
		_BUILDING + "coral_citadel_rampart_test.gd": ["rampart"],
		"res://domain/worksite/tests/worksite_rules_test.gd": ["worksites"],
	},
	"resources": {
		_RESOURCE + "resource_vectors_test.gd": [
			"storage", "credit", "energyConsumption", "totalConsumption", "production",
		],
		_RESOURCE + "production_formulas_test.gd": ["buildingProduction"],
		PENDING + "game": ["startingStocks"],
	},
	"units": {
		"res://domain/unit/tests/unit_vectors_test.gd": [
			"units", "maxRecruitable", "hungerLosses", "hungerLossesAllLevels",
		],
		"res://domain/fight/tests/unit_boost_test.gd": ["boost"],
	},
	"tech": {
		"res://domain/tech/tests/tech_vectors_test.gd": [
			"unlockCost", "researchCost", "branchState", "effects",
		],
	},
	"fight_rules": {
		PENDING + "fight": ["damage", "attackDamage", "monsters", "monsterLevels", "guardians"],
		PENDING + "volcano": ["magmaRampart"],
		PENDING + "leviathan": ["leviathan"],
	},
	"fight_engine": {PENDING + "fight": ["resolve", "critChance", "twoFights"]},
	"fight_aftermath": {
		PENDING + "fight": ["woundedProbability", "casualties", "lairLoot"],
		PENDING + "action": ["pctLost", "treasureLoot"],
	},
	"fight_planning": {
		PENDING + "fight": ["strength", "rehearsal", "planner", "assaultChance", "assaultRating"],
	},
	"map_rules": {
		PENDING + "map": [
			"layout", "lairFamily", "lair", "startingBases", "reveal", "posts", "volcano",
		],
	},
	"maps": {PENDING + "map": ["world", "level"]},
	"events": {PENDING + "event": ["drawTurns", "pick", "survivors", "production"]},
	"raids": {
		PENDING + "raid": ["wave", "everyWave", "defenceStrength", "loot", "pillage", "upgradeNoise"],
		PENDING + "volcano": ["krakens"],
		"res://domain/game/tests/difficulty_test.gd": ["monsterPercent"],
	},
	"factions": {
		PENDING + "faction": [
			"draw", "traits", "slots", "siege", "siegesPerTurn", "explorationBias",
		],
	},
}


## The states that list the section of the file: one for a section in
## order, none for a forgotten one.
static func states_of(file_name: String, section: String) -> PackedStringArray:
	var found := PackedStringArray()
	var states: Dictionary = FILES.get(file_name, {})
	for state: String in states:
		var sections: Array = states[state]
		for _listed: int in sections.count(section):
			found.append(state)
	return found


## Whether a state waits for a module, and which.
static func pending_module(state: String) -> String:
	return state.trim_prefix(PENDING) if state.begins_with(PENDING) else ""
