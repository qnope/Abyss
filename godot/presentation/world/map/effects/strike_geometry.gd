class_name StrikeGeometry
extends RefCounted
## Where an army goes on the map as it attacks what stands on [member target]
## (the top left of a place [member span] cells across), having set off from
## [member origin] (lib/presentation/widgets/map/effects/strike/
## strike_geometry.dart): it swims to the [method approach] cell beside the
## place, lunges part of the way towards its middle, and may retreat a cell.
## Positions are the map's, in metres, on the floor.

## Share of the way to the lair a lunge reaches.
const LUNGE_REACH := 0.45

var origin: Vector2i
var target: Vector2i
var span: int
## Size of the map in cells.
var width: int
var height: int


func _init(origin_: Vector2i, target_: Vector2i, width_: int, height_: int, span_ := 1) -> void:
	origin = origin_
	target = target_
	width = width_
	height = height_
	span = span_


## The cell beside the place the army attacks from.
func approach() -> Vector2i:
	return approach_cell(origin, target, width, height, span)


## The cell beside the place [param span] cells across from [param target],
## inside a map of [param width] by [param height], the army attacks from: on
## screen it lies left or right of the place or in front of it, never behind,
## where it would hide the place. Of those, the one nearest [param origin] (the
## origin itself when it touches the place there), a side before the front, the
## upper one, then the left one; from within the place, the first of them. Only
## where none lies inside the map does the army come from behind.
static func approach_cell(
	origin_: Vector2i, target_: Vector2i, width_: int, height_: int, span_ := 1
) -> Vector2i:
	var within := covers(target_, span_, origin_)
	var best := origin_
	var best_rank: Array[int] = []
	for x in range(target_.x - 1, target_.x + span_ + 1):
		for y in range(target_.y - 1, target_.y + span_ + 1):
			var cell := Vector2i(x, y)
			if x < 0 or y < 0 or x >= width_ or y >= height_ or covers(target_, span_, cell):
				continue
			var rank: Array[int] = [
				0 if y >= target_.y else 1,
				0 if within else (cell - origin_).length_squared(),
				1 if y >= target_.y + span_ else 0, y, x,
			]
			if best_rank.is_empty() or rank < best_rank:
				best = cell
				best_rank = rank
	return best


## Whether [param cell] lies in the place [param span_] cells across from [param target_].
static func covers(target_: Vector2i, span_: int, cell: Vector2i) -> bool:
	return cell.x >= target_.x and cell.x < target_.x + span_ \
		and cell.y >= target_.y and cell.y < target_.y + span_


## The middle of the place on the floor: the army lunges at it.
func lair() -> Vector3:
	return MapGrid.at(target.x, target.y, width, height) \
		+ Vector3(1.0, 0.0, 1.0) * (span - 1) * MapGrid.CELL / 2.0


## The army after [param swim] of its swim (0 to 1), lunging [param reach] of
## its way to the place and having retreated [param retreat] of a cell.
func army_at(swim: float, reach := 0.0, retreat := 0.0) -> Vector3:
	var start := MapGrid.at(origin.x, origin.y, width, height)
	var rest := MapGrid.at(approach().x, approach().y, width, height)
	var swum := start.lerp(rest, MapMotion.travel(swim))
	var toward := lair() - rest
	return swum + toward * (LUNGE_REACH * reach) + _away(rest, start) * (MapMotion.travel(retreat) * MapGrid.CELL)


## One cell's length from [param from], back towards the origin, or straight away
## from the place when the army set off beside or within it.
func _away(from: Vector3, start: Vector3) -> Vector3:
	var away := start - from
	if away.length() < 1e-3 or covers(target, span, origin):
		away = from - lair()
	return away.normalized()
