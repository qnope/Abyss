class_name FogLifts
extends RefCounted
## What the fog lifts from: it remembers the cells seen of each level the map
## showed, and tells which cells a new state sees for the first time (the
## cells a scout's exploration revealed since). A level shown for the first
## time has none, nor has a game that is not the one before (its cells are not
## a growth of the ones remembered).

var _known: Dictionary[int, Dictionary] = {}


## Forgets every level: the next one shown lifts nothing.
func forget() -> void:
	_known.clear()


## The cells of [param looks] (the level [param level]) seen now and not when
## it was last shown, in the order of the grid.
func newly_seen(level: int, looks: Array[MapLook]) -> Array[Vector2i]:
	var seen: Dictionary = {}
	for look in looks:
		if look.revealed:
			seen[look.key()] = true
	var was: Dictionary = _known.get(level, {})
	_known[level] = seen
	var found: Array[Vector2i] = []
	if was.is_empty() or not was.keys().all(func(key: Vector2i) -> bool: return seen.has(key)):
		return found
	for look in looks:
		if look.revealed and not was.has(look.key()):
			found.append(look.key())
	return found


## The cells of [param looks] still under the fog.
static func hidden(looks: Array[MapLook]) -> Dictionary[Vector2i, bool]:
	var found: Dictionary[Vector2i, bool] = {}
	for look in looks:
		if not look.revealed:
			found[look.key()] = true
	return found
