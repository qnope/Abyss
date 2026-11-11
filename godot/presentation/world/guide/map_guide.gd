class_name MapGuide
extends GuideRing
## The guide's ring on the map (lib/.../guide_cell_halo.dart): around the cell
## the tutorial points at, on the level it is on, and nowhere on another. The
## cell is aimed once; the ring follows the level the map shows
## ([method shown_on]), so that a level opened later finds its cell ringed.

## How wide the ring is in cells, as Flutter's halo is the cell's own box.
const SHARE := 0.55
## Its thickness in metres, over tiles of a light blue.
const MAP_TUBE := 0.14

var has_aim := false
var _aim := Vector3i.ZERO
var _state: MapLevelState


func _init() -> void:
	super()
	tube = MAP_TUBE


## Rings the cell ([param x], [param y]) of [param level].
func aim(level: int, x: int, y: int) -> void:
	has_aim = true
	_aim = Vector3i(level, x, y)
	_follow()


## Takes the aim away.
func release() -> void:
	has_aim = false
	clear()


## The map shows [param state] now.
func shown_on(state: MapLevelState) -> void:
	_state = state
	_follow()


func _follow() -> void:
	if not has_aim or _state == null or _state.level != _aim.x:
		clear()
		return
	point_at(MapGrid.at(_aim.y, _aim.z, _state.map.width, _state.map.height), MapGrid.CELL * SHARE)
