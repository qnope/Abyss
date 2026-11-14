class_name Bench
extends Node
## A run measured the same way each time: after a warm-up, every frame of a
## set time is timed; at the end its average frame rate, its 1 % low, its
## worst frame and the count of its slow frames show on the frame counter,
## with the name of what was measured, and are printed. What happens during
## the run is its own: [BenchRun] moves the camera over a scene, [ActionBench]
## plays the actions of a game.

## Its summary, once it is over.
signal finished(summary: String)

## Seconds left out at first: shaders compiling, particles settling.
const WARM_UP := 2.0

var stats := FrameStats.new(INF)
var _counter: FrameCounter
var _seconds: float
var _subject: String
var _time := 0.0
var _done := false


## [param subject] names what is measured in the summary.
func _init(counter: FrameCounter, seconds: float, subject: String) -> void:
	_counter = counter
	_seconds = seconds
	_subject = subject


func _process(delta: float) -> void:
	_time += delta
	var t := _time - WARM_UP
	# A frame that began during the warm-up is left out.
	if t - delta < 0.0 or _done:
		return
	# The time is up: asked on each frame until the run is over.
	if t > _seconds:
		_finish()
		return
	stats.add(delta)
	_step(t, delta)


## What the run does [param _t] seconds into its time, on each frame timed;
## the frame before took [param _delta] seconds.
func _step(_t: float, _delta: float) -> void:
	pass


## The summary of the run.
func _summary() -> String:
	return FrameReport.bench(stats, _seconds, _subject)


## Ends the run and tells its summary.
func _finish() -> void:
	_done = true
	set_process(false)
	var summary := _summary()
	print(summary)
	_counter.show_bench(summary)
	finished.emit(summary)
