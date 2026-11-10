class_name BenchRun
extends Node
## A run measuring the scene the same way each time: after a warm-up, the
## camera turns once around the base from the game's view, zooming in and
## out, for a set time. Every frame of it is timed; at the end its average
## frame rate and its 1 % low show on the frame counter, and are printed.

## Its summary, once it is over.
signal finished(summary: String)

## Seconds left out at first: shaders compiling, particles settling.
const WARM_UP := 2.0
## How far the view zooms in at the middle of the turn, from the default.
const ZOOM := 0.55

var stats := FrameStats.new(INF)
var _camera: OrbitCamera
var _counter: FrameCounter
var _seconds: float
var _time := 0.0
var _done := false


func _init(camera: OrbitCamera, counter: FrameCounter, seconds: float) -> void:
	_camera = camera
	_counter = counter
	_seconds = seconds


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
	var zoom := 1.0 - (1.0 - ZOOM) * sin(PI * share)
	_camera.rig.look(OrbitRig.DEFAULT_YAW + 360.0 * share, OrbitRig.DEFAULT_PITCH,
		OrbitRig.DEFAULT_DISTANCE * zoom)


func _finish() -> void:
	_done = true
	set_process(false)
	var summary := FrameReport.bench(stats, _seconds)
	print(summary)
	_counter.show_bench(summary)
	_camera.rig.look(OrbitRig.DEFAULT_YAW, OrbitRig.DEFAULT_PITCH, OrbitRig.DEFAULT_DISTANCE)
	finished.emit(summary)
