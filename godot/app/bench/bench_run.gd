class_name BenchRun
extends Bench
## The bench of a scene: during the run the camera goes once around the scene
## from the game's view (a [BenchPose]: a turn round the base, a loop over the
## map), zooming in and out, and comes back to that view at the end.

## How far the view zooms in at the middle of the run, from the default.
const ZOOM := 0.55

var _pose: Callable


## [param pose] puts the camera at a share of the run and a zoom
## (`func(share: float, zoom: float)`); without one it turns round the base
## of [param camera]. [param subject] names the scene in the summary.
func _init(camera: OrbitCamera, counter: FrameCounter, seconds: float, pose := Callable(),
		subject := "base") -> void:
	super(counter, seconds, subject)
	_pose = pose if pose.is_valid() else BenchPose.orbit.bind(camera.rig)


func _step(t: float, _delta: float) -> void:
	var share := t / _seconds
	_pose.call(share, 1.0 - (1.0 - ZOOM) * sin(PI * share))


func _finish() -> void:
	_pose.call(0.0, 1.0)
	super()
