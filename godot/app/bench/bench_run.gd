class_name BenchRun
extends Node
## A run measuring the scene the same way each time: after a warm-up, the
## camera goes once around the scene from the game's view (a [BenchPose]: a
## turn round the base, a loop over the map), zooming in and out, for a set
## time. Every frame of it is timed; at the end its average frame rate, its
## 1 % low, its worst frame and the count of its slow frames show on the frame
## counter, with the name of the scene measured, and are printed.

## Its summary, once it is over.
signal finished(summary: String)

## Seconds left out at first: shaders compiling, particles settling.
const WARM_UP := 2.0
## How far the view zooms in at the middle of the run, from the default.
const ZOOM := 0.55

var stats := FrameStats.new(INF)
var _pose: Callable
var _counter: FrameCounter
var _seconds: float
var _subject: String
var _time := 0.0
var _done := false


## [param pose] puts the camera at a share of the run and a zoom
## (`func(share: float, zoom: float)`); without one it turns round the base
## of [param camera]. [param subject] names the scene in the summary.
func _init(camera: OrbitCamera, counter: FrameCounter, seconds: float, pose := Callable(),
		subject := "base") -> void:
	_pose = pose if pose.is_valid() else BenchPose.orbit.bind(camera.rig)
	_counter = counter
	_seconds = seconds
	_subject = subject


func _process(delta: float) -> void:
	_time += delta
	var t := _time - WARM_UP
	# A frame that began during the warm-up is left out.
	if t - delta < 0.0 or _done:
		return
	if t > _seconds:
		_finish()
		return
	stats.add(delta)
	var share := t / _seconds
	_pose.call(share, 1.0 - (1.0 - ZOOM) * sin(PI * share))


func _finish() -> void:
	_done = true
	set_process(false)
	var summary := FrameReport.bench(stats, _seconds, _subject)
	print(summary)
	_counter.show_bench(summary)
	_pose.call(0.0, 1.0)
	finished.emit(summary)
