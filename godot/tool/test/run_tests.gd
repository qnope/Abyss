extends SceneTree
## Runs the tests from the command line:
##
##     godot --headless --path godot --script res://tool/test/run_tests.gd -- [paths...]
##
## Paths are test files or folders, `res://` or relative to godot/; without
## any, every `*_test.gd` of the project runs. Prints a line per failed test
## and a summary, and exits with 1 when a test failed, 0 otherwise. With
## `--coverage-out=<file>`, an instrumented copy of the project also writes
## its hits there (see TestCoverageDump). With `--timeout=<seconds>` (600 by
## default), a run that has not finished by then exits with 1 (TestWatchdog).

var _options := TestRunOptions.new(OS.get_cmdline_user_args())
var _watchdog := TestWatchdog.new(self, _options.timeout_seconds)


func _init() -> void:
	# Run once the tree is up, on the first frame, so tests can use its root.
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var run := TestSuite.run(TestDiscovery.find(_options.paths))
	for line: String in run.report_lines():
		print(line)
	var code := run.exit_code()
	if not _options.coverage_out.is_empty():
		var error := TestCoverageDump.write(_options.coverage_out)
		if not error.is_empty():
			printerr(error)
			code = 1
	_watchdog.stop()
	quit(code)
