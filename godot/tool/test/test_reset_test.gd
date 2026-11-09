extends TestCase
## TestReset runs the listed resets of static state before each test file.

const ResetProbe := preload("res://tool/test/fixtures/reset_probe.gd")
const COUNTING := "res://tool/test/fixtures/counting_test.gd"


func test_reset_all_runs_the_given_resets() -> void:
	ResetProbe.count = 3
	TestReset.reset_all([ResetProbe.debug_reset])
	assert_eq(ResetProbe.count, 0)


func test_the_suite_runs_the_resets_before_each_file() -> void:
	ResetProbe.count = 7
	var run := TestSuite.run(PackedStringArray([COUNTING, COUNTING]), [ResetProbe.debug_reset])
	assert_eq(run.test_count(), 2)
	assert_eq(run.failed_count(), 0)
	assert_eq(ResetProbe.count, 1)


func test_the_process_resets_are_static_functions_named_debug_reset() -> void:
	for reset: Callable in ProcessResets.all():
		assert_true(reset.is_valid(), str(reset))
		assert_eq(reset.get_method(), &"debug_reset", str(reset))
