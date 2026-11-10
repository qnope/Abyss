class_name TestWatchdog
extends RefCounted
## Ends a test run that does not finish in time: once the tree has turned for
## the given seconds without stop(), prints why and quits with 1. A script
## error stops the GDScript function it hits, so one in the runner's own code
## before its quit() would leave the process idling forever. An endless loop
## never lets the tree turn again: tool/godot_test.sh's `timeout` covers it.

var _tree: SceneTree
var _seconds: float
var _timer: SceneTreeTimer


func _init(tree: SceneTree, seconds: float) -> void:
	_tree = tree
	_seconds = seconds
	_timer = tree.create_timer(seconds, true, false, true)
	_timer.timeout.connect(_expire)


## Called once the run has ended, before its own quit().
func stop() -> void:
	_timer.timeout.disconnect(_expire)


func _expire() -> void:
	printerr("The test run did not finish within %s s." % _seconds)
	_tree.quit(1)
