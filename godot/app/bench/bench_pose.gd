class_name BenchPose
extends RefCounted
## Where a bench puts the camera at a share of its run (0 to 1), with the
## zoom of that moment (1 for the default view, less for closer): the same path
## each time, so that two runs of a scene compare.

## How far over the map the view wanders, as a share of its smaller side.
const PAN_REACH := 0.2


## Round the base: one turn from the game's view. (The rig comes last, so that
## a Callable can bind it: the bench calls `pose.call(share, zoom)`.)
static func orbit(share: float, zoom: float, rig: OrbitRig) -> void:
	rig.look(OrbitRig.DEFAULT_YAW + 360.0 * share, OrbitRig.DEFAULT_PITCH, rig.default_distance * zoom)


## Over the map: a loop around the middle, from the default view back to it.
static func pan(share: float, zoom: float, rig: MapRig) -> void:
	rig.look(MapRig.YAW, MapRig.PITCH, rig.default_distance * zoom)
	var reach := minf(rig.bounds.size.x, rig.bounds.size.y) * PAN_REACH
	rig.target = Vector3(sin(TAU * share), 0.0, (cos(TAU * share) - 1.0) * 0.5) * reach
