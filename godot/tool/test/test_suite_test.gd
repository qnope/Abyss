extends TestCase
## Runs the fixtures through the runner's core, in this process.

const FIXTURES := "res://tool/test/fixtures/"
const PASSING := FIXTURES + "passing_test.gd"
const FAILING := FIXTURES + "failing_test.gd"
const HooksFixture := preload("res://tool/test/fixtures/hooks_test.gd")


func test_counts_the_tests_of_a_passing_file() -> void:
	var run := TestSuite.run(PackedStringArray([PASSING]))
	assert_eq(run.test_count(), 3)
	assert_eq(run.failed_count(), 0)
	assert_eq(run.exit_code(), 0)


func test_counts_the_failed_tests() -> void:
	var run := TestSuite.run(PackedStringArray([PASSING, FAILING]))
	assert_eq(run.test_count(), 6)
	assert_eq(run.failed_count(), 2)


func test_exits_with_1_when_a_test_failed() -> void:
	assert_eq(TestSuite.run(PackedStringArray([FAILING])).exit_code(), 1)


func test_names_the_file_and_the_test_of_a_failure() -> void:
	var failed := TestSuite.run(PackedStringArray([FAILING])).failed()
	assert_eq(failed.size(), 2)
	assert_eq(failed[0].file, FAILING)
	assert_eq(failed[0].name, "test_adds_wrongly")
	assert_eq(failed[0].failures, PackedStringArray(["the sum: expected 4, got 5"]))


func test_reports_each_failure_of_a_test_on_one_line() -> void:
	var lines := TestSuite.run(PackedStringArray([FAILING])).report_lines()
	assert_eq(lines.size(), 3)
	assert_eq(
		lines[1],
		"FAIL %s::test_fails_twice: expected null, got 1; on purpose" % FAILING
	)


func test_sums_up_the_run() -> void:
	var summary := TestSuite.run(PackedStringArray([PASSING, FAILING])).summary()
	var pattern := RegEx.create_from_string("^6 tests, 2 failed, in \\d+ ms$")
	assert_not_null(pattern.search(summary), summary)


func test_runs_each_test_on_a_fresh_instance_between_its_hooks() -> void:
	HooksFixture.events = PackedStringArray()
	var run := TestSuite.run(PackedStringArray([FIXTURES + "hooks_test.gd"]))
	assert_eq(run.failed_count(), 0)
	assert_eq(
		HooksFixture.events,
		PackedStringArray(["before", "first", "after", "before", "second", "after"])
	)


func test_fails_a_missing_file() -> void:
	var failed := TestSuite.run(PackedStringArray([FIXTURES + "missing_test.gd"])).failed()
	assert_eq(failed.size(), 1)
	assert_has(failed[0].failures[0], "no such test file")


func test_fails_a_script_that_is_not_a_test_case() -> void:
	var failed := TestSuite.run(PackedStringArray([FIXTURES + "reset_probe.gd"])).failed()
	assert_eq(failed.size(), 1)
	assert_has(failed[0].failures[0], "does not extend TestCase")
