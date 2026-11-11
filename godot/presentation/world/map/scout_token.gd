class_name ScoutToken
extends Node3D
## A scout on its way to a cell (lib/presentation/widgets/map/token/): the
## unit's figure ([WorldModels.unit], a stand-in until step 7) floating over
## the cell it was sent to. One just sent swims there from the cell it set off
## from; one already on its way, when the map is shown, waits there at once.

## How long the swim lasts, in seconds, and how high the scout floats.
const SWIM := 0.9
const HOVER := 0.7

var from: Vector3
var to: Vector3
## How far along the swim it is, from 0 to 1.
var progress: float


## A scout going from [param from_] to [param to_] (on the floor): it swims
## when [param swims], else it is there.
func _init(from_: Vector3, to_: Vector3, swims: bool) -> void:
	from = from_
	to = to_
	progress = 0.0 if swims else 1.0
	add_child(WorldModels.unit(UnitType.Value.SCOUT))
	_place()


func is_swimming() -> bool:
	return progress < 1.0


## Moves the scout [param seconds] along its swim.
func advance(seconds: float) -> void:
	progress = minf(progress + seconds / SWIM, 1.0)
	_place()


func _place() -> void:
	position = from.lerp(to, smoothstep(0.0, 1.0, progress)) + Vector3.UP * HOVER
