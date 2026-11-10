extends SceneTree
## A runner that never quits by itself, as one whose code stopped on a script
## error before its quit(): only its watchdog ends it (test_watchdog_test.gd).

var _watchdog: TestWatchdog


func _init() -> void:
	_watchdog = TestWatchdog.new(self, 0.2)
