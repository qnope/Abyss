class_name LongCases
extends RefCounted
## The tests of whole games too long for the unit tests, which the runner
## plays beside the reference games, by name. Each gives what it found
## wrong, nothing when it passes.

const NAMES: Array[String] = ["faction-attack-play", "faction-play-10", "faction-play-3", "faction-research-play"]


static func run(name: String) -> PackedStringArray:
	match name:
		"faction-play-10":
			return FactionPlayCases.grow(10)
		"faction-play-3":
			return FactionPlayCases.grow(3)
		"faction-research-play":
			return FactionPlayCases.research()
	return FactionAttackCases.run()
