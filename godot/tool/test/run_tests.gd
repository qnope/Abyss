extends SceneTree
## Runs the tests from the command line:
##
##     godot --headless --path godot --script res://tool/test/run_tests.gd -- [paths...]
##
## Paths are test files or folders, `res://` or relative to godot/; without
## any, every `*_test.gd` of the project runs. Prints a line per failed test
## and a summary, and exits with 1 when a test failed, 0 otherwise.


func _init() -> void:
	# Run once the tree is up, on the first frame, so tests can use its root.
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var run := TestSuite.run(TestDiscovery.find(OS.get_cmdline_user_args()))
	for line: String in run.report_lines():
		print(line)
	quit(run.exit_code())
