class_name LongCases
extends RefCounted
## The tests of whole games too long for the unit tests, which the runner
## plays beside the reference games, by name. Each gives what it found
## wrong, nothing when it passes.

const _NAMES: Array[String] = [
	"calibration", "faction-attack-play", "faction-play-10", "faction-play-3", "faction-research-play",
	"script-performance", "careful-script",
]


## Every case, those of `faction_race_test.dart` (FactionRaceCases) last.
static func names() -> Array[String]:
	var all := _NAMES.duplicate()
	all.append_array(FactionRaceCases.names())
	return all


static func run(name: String) -> PackedStringArray:
	if name.begins_with(FactionRaceCases.PREFIX):
		return FactionRaceCases.run(name)
	match name:
		"calibration":
			return ScriptCases.calibration()
		"careful-script":
			return ScriptCases.careful_script()
		"script-performance":
			return ScriptCases.performance()
		"faction-play-10":
			return FactionPlayCases.grow(10)
		"faction-play-3":
			return FactionPlayCases.grow(3)
		"faction-research-play":
			return FactionPlayCases.research()
	return FactionAttackCases.run()
