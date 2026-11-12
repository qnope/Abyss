class_name MapCamera
extends OrbitCamera
## The camera of the map: it pans after the player's drag, zooms on a pinch,
## and tells a tap (OrbitCamera's gestures, on a [MapRig]). Its default view is
## fitted to the screen with the whole map showing, between the bars of the
## game screen.

## The view, which pans where the base's orbits.
var pan := MapRig.new()
## How far a blow shakes the view to the side, in metres (see [MapEffects]).
var jolt := 0.0


func _init() -> void:
	super(pan)


func _process(delta: float) -> void:
	super(delta)
	position += basis.x * jolt


## Fits the default view to a map of [param width] by [param height] cells,
## between the top [param hud] share of the screen and its bottom
## [param foot] share. The view may then pan within the map.
func fit_map(width: int, height: int, hud: float, foot := 0.0) -> void:
	fit(MapGrid.outline(width, height), hud, foot, MapRig.YAW, MapRig.PITCH)
	var half := Vector2(width, height) * MapGrid.CELL / 2.0
	pan.bounds = Rect2(-half, half * 2.0)


## Puts the view back on the middle of the map, at the default zoom.
func home() -> void:
	pan.home()
	transform = pan.transform()
