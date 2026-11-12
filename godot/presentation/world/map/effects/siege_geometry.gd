class_name SiegeGeometry
extends RefCounted
## Where the attackers of a place go (lib/presentation/widgets/map/effects/story/
## siege_geometry.dart): the place covers [member span] cells across from
## [member place], its top left cell; [constant ATTACKERS] figures close in on it
## from around, then are pushed back or break in. Positions are the map's, in
## metres, on the floor.

## Number of attackers shown.
const ATTACKERS := 3
## How far the attackers set off, in cells beyond the place's edge.
const START := 2.5
## How far they stop from the place's edge, in cells.
const HALT := 0.35
## Share of the way from where they halted to the place's edge a lunge reaches.
const LUNGE_REACH := 0.8
## How far they are pushed back, in cells beyond where they halted.
const PUSH := 1.5

var place: Vector2i
var span: int
## Size of the map in cells.
var width: int
var height: int


func _init(place_: Vector2i, width_: int, height_: int, span_ := 1) -> void:
	place = place_
	width = width_
	height = height_
	span = span_


## The middle of the place, on the floor.
func center() -> Vector3:
	return MapGrid.at(place.x, place.y, width, height) \
		+ Vector3(1.0, 0.0, 1.0) * (span - 1) * MapGrid.CELL / 2.0


## The radius of the circle through the corners of the place: rings drawn from it
## surround what stands there.
func radius() -> float:
	return span * MapGrid.CELL * sqrt(0.5)


## Attacker [param index] after [param approach] of its way in (0 to 1), lunging
## [param reach] of the way at the place, pushed back [param pushed] of the way,
## or [param breach] of its way into the place.
func attacker_at(index: int, approach: float, reach := 0.0, pushed := 0.0, breach := 0.0) -> Vector3:
	var angle := -PI / 2.0 + index * TAU / ATTACKERS + 0.4
	var halted := radius() + HALT * MapGrid.CELL
	var far := radius() + START * MapGrid.CELL
	var distance := lerpf(far, halted, MapMotion.travel(approach))
	distance -= HALT * MapGrid.CELL * LUNGE_REACH * reach
	distance += PUSH * MapGrid.CELL * MapMotion.enter(pushed)
	distance -= halted * MapMotion.exit(breach)
	return center() + Vector3(cos(angle), 0.0, sin(angle)) * distance
