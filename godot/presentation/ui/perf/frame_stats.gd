class_name FrameStats
extends RefCounted
## The times of the frames drawn over the last [member window] seconds, or
## of a whole run when the window is INF: the frame rate, the average and
## worst frame times, and the rate of the slowest frames (the "1 % low").

## How far back the frames count, in seconds.
var window: float
## Each frame's time, in seconds, the oldest first.
var _times := PackedFloat32Array()
var _total := 0.0


func _init(window_: float) -> void:
	window = window_


## Counts a frame that took [param seconds].
func add(seconds: float) -> void:
	_times.append(seconds)
	_total += seconds
	while _times.size() > 1 and _total - _times[0] >= window:
		_total -= _times[0]
		_times.remove_at(0)


func clear() -> void:
	_times.clear()
	_total = 0.0


func count() -> int:
	return _times.size()


## The frames per second over the window, or 0 before the first frame.
func fps() -> float:
	return _times.size() / _total if _total > 0.0 else 0.0


func average_ms() -> float:
	return _total / _times.size() * 1000.0 if _total > 0.0 else 0.0


func worst_ms() -> float:
	var worst := 0.0
	for seconds in _times:
		worst = maxf(worst, seconds)
	return worst * 1000.0


## The frame rate of the slowest [param share] of the frames (at least
## one): 0.01 gives the "1 % low".
func low_fps(share: float) -> float:
	if _times.is_empty():
		return 0.0
	var sorted := _times.duplicate()
	sorted.sort()
	var slowest := maxi(1, ceili(sorted.size() * share))
	var total := 0.0
	for index in slowest:
		total += sorted[sorted.size() - 1 - index]
	return slowest / total
