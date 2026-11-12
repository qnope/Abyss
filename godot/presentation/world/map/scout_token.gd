class_name ScoutToken
extends Node3D
## A scout on its way to a cell (lib/presentation/widgets/map/token/): the
## unit's figure ([WorldModels.unit]) floating over the cell it was sent to. One
## just sent swims there from the cell it set off from, as long as Flutter's
## token ([MapMotion.swim_over], longer over a farther cell), and shrinks onto
## the cell as it arrives, to wait there; one already on its way, when the map
## is shown, waits there at once. A scout whose exploration is over leaves
## ([method leave]): it rises and shrinks away with the fog the story lifts.

## How high the scout floats.
const HOVER := 0.7
## How much of its swimming size it keeps once it waits (Flutter's 0.45 of a
## cell over 0.6).
const REST_SCALE := 0.75
## How high it rises as it leaves.
const LEAVE_RISE := 0.5

var from: Vector3
var to: Vector3
## How far along the swim it is, from 0 to 1.
var progress: float
## How long its swim lasts, in seconds.
var swim := MapMotion.SWIM
## How far it has left, from 0 (there) to 1 (gone).
var gone := 0.0
var _animator: ModelAnimator


## A scout going from [param from_] to [param to_] (on the floor): it swims
## when [param swims], else it is there.
func _init(from_: Vector3, to_: Vector3, swims: bool) -> void:
	from = from_
	to = to_
	progress = 0.0 if swims else 1.0
	swim = MapMotion.swim_over(from.distance_to(to) / MapGrid.CELL)
	var figure := WorldModels.unit(UnitType.Value.SCOUT)
	add_child(figure)
	_animator = WorldModels.animator(figure)
	_play(&"swim" if swims else &"idle")
	_place()


func is_swimming() -> bool:
	return progress < 1.0


## Moves the scout [param seconds] along its swim.
func advance(seconds: float) -> void:
	progress = minf(progress + seconds / swim, 1.0)
	_place()
	_play(&"idle" if progress >= 1.0 else &"swim")


## Sets how far the scout has left, from 0 to 1: it rises and shrinks away.
func leave(share: float) -> void:
	gone = clampf(share, 0.0, 1.0)
	_place()


func _play(animation: StringName) -> void:
	if _animator != null and _animator.current() != animation:
		_animator.play(animation)


func _place() -> void:
	var moved := smoothstep(0.0, 1.0, progress)
	position = from.lerp(to, moved) + Vector3.UP * (HOVER + LEAVE_RISE * gone)
	# Never nothing at all: a node cannot be inverted.
	scale = Vector3.ONE * maxf(lerpf(lerpf(1.0, REST_SCALE, moved), 0.0, gone), 0.001)
