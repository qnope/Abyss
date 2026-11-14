class_name ManualFrames
extends RefCounted
## The frames of a test, which pass when it says so: what a [NextFrame] is
## given in place of the scene tree's, since the tests run in one frame.

## What the scene tree tells with `process_frame`.
signal told

## The engine's count of the frames processed.
var number := 0


## A wait on these frames.
func next_frame() -> NextFrame:
	return NextFrame.new(told, func() -> int: return number)


## The frame going on is told: as the tree tells the frame of a touch, after
## the touch and before the frame is drawn.
func tell() -> void:
	told.emit()


## The frame going on is over and the next is told.
func pass_one() -> void:
	number += 1
	told.emit()
