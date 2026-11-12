class_name MapAmbient
extends CreatureLap
## The creature of the level (a turtle, a jelly, a ray) that swims round the
## slab of the map, a lap every [constant LAP] seconds ([CreatureLap]).

## Seconds a lap takes.
const LAP := 80.0
## How far beyond the slab's edge it swims, and how high above the floor.
const ROOM := 1.5
const HEIGHT := 0.9


## Sets the creature of [param level] swimming round a map of [param width] by
## [param height] cells, in place of the one before.
func show_level(level: int, width: int, height: int) -> void:
	swim(MapScenery.CREATURES[MapScenery.index_of(level)],
		Vector2(width, height) / 2.0 + Vector2.ONE * ROOM, HEIGHT, LAP)
