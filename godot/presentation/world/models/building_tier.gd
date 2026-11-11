class_name BuildingTier
extends RefCounted
## How far a building has risen, in the bands the Flutter base draws its
## pads in (base_pad_tier.dart): none while it is to build, then levels 1 to
## 3, 4 to 7 and 8 and up. A stand-in grows with its tier; the coral rampart
## has its own bands, three for the citadel's five levels.

## The first level of each band of the pads (tier 1, 2 and 3).
const PAD_STARTS: Array[int] = [1, 4, 8]
## The first level of the citadel that raises each tier of the rampart.
const RAMPART_STARTS: Array[int] = [1, 3, 5]


## The tier of the pad under a building at [param level]: 0 for none.
static func of_level(level: int) -> int:
	return _band(level, PAD_STARTS)


## The tier of the rampart a Coral Citadel at [param level] raises: 0 for
## none, 1 to 3.
static func rampart_of(level: int) -> int:
	return _band(level, RAMPART_STARTS)


static func _band(level: int, starts: Array[int]) -> int:
	var band := 0
	for start in starts:
		if level >= start:
			band += 1
	return band
