class_name LongCases
extends RefCounted
## The tests of whole games too long for the unit tests, which the runner
## plays beside the reference games, by name. Each gives what it found
## wrong, nothing when it passes.

const NAMES: Array[String] = [
	"calibration", "faction-attack-play", "faction-play-10", "faction-play-3", "faction-research-play",
	"script-performance", "careful-script",
]


static func run(name: String) -> PackedStringArray:
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
