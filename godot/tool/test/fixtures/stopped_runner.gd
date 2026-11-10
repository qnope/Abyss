extends SceneTree
## A runner that stops its watchdog, then quits with 0 after the watchdog's
## time has passed (test_watchdog_test.gd).

var _watchdog: TestWatchdog


func _init() -> void:
	_watchdog = TestWatchdog.new(self, 0.1)
	_watchdog.stop()
	create_timer(0.4).timeout.connect(quit.bind(0))
