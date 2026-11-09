extends SceneTree
## Runs the tests from the command line:
##
##     godot --headless --path godot --script res://tool/test/run_tests.gd -- [paths...]
##
## Paths are test files or folders, `res://` or relative to godot/; without
## any, every `*_test.gd` of the project runs. Prints a line per failed test
## and a summary, and exits with 1 when a test failed, 0 otherwise. With
## `--coverage-out=<file>`, an instrumented copy of the project also writes
## its hits there (see TestCoverageDump).


func _init() -> void:
	# Run once the tree is up, on the first frame, so tests can use its root.
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var options := TestRunOptions.new(OS.get_cmdline_user_args())
	var run := TestSuite.run(TestDiscovery.find(options.paths))
	for line: String in run.report_lines():
		print(line)
	var code := run.exit_code()
	if not options.coverage_out.is_empty():
		var error := TestCoverageDump.write(options.coverage_out)
		if not error.is_empty():
			printerr(error)
			code = 1
	quit(code)
