class_name TestSuite
extends RefCounted
## Runs test files one after the other in this process, each after
## TestReset.reset_all() so that it starts as in a fresh process.


## Runs the files, each after the given resets, by default ProcessResets'.
static func run(
	files: PackedStringArray, resets: Array[Callable] = ProcessResets.all()
) -> TestRun:
	var test_run := TestRun.new()
	var start := Time.get_ticks_msec()
	for file: String in files:
		TestReset.reset_all(resets)
		test_run.results.append_array(TestFileRunner.run(file))
	test_run.elapsed_msec = Time.get_ticks_msec() - start
	return test_run
