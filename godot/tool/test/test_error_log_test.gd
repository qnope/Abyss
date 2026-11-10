extends TestCase
## A test names the errors it expects the code to log: each lets one error
## pass, the others still fail it, and so does an expected error that never
## came.

const FIXTURE := "res://tool/test/fixtures/expected_error_test.gd"


func test_every_error_fails_a_test_that_expects_none() -> void:
	var errors := PackedStringArray(["first (a.gd:1)", "second (a.gd:2)"])
	assert_eq(TestErrorLog.unexpected(errors, PackedStringArray()), errors)


func test_an_expected_part_lets_one_error_holding_it_pass() -> void:
	var errors := PackedStringArray(["first (a.gd:1)", "second (a.gd:2)"])
	assert_eq(
		TestErrorLog.unexpected(errors, PackedStringArray(["second"])),
		PackedStringArray(["first (a.gd:1)"])
	)
	assert_eq(errors.size(), 2, "the log is left as it was")


func test_an_expected_part_lets_only_one_error_pass() -> void:
	var errors := PackedStringArray(["refused 0", "refused -1"])
	assert_eq(
		TestErrorLog.unexpected(errors, PackedStringArray(["refused"])),
		PackedStringArray(["refused -1"])
	)
	assert_eq(
		TestErrorLog.unexpected(errors, PackedStringArray(["refused", "refused"])),
		PackedStringArray()
	)


func test_an_expected_error_that_never_came_is_a_failure() -> void:
	assert_eq(
		TestErrorLog.unexpected(PackedStringArray(["first"]), PackedStringArray(["second"])),
		PackedStringArray(["first", 'expected an error holding "second", none was logged'])
	)


func test_the_runner_lets_a_test_expect_the_errors_it_logs() -> void:
	# The fixture's errors reach this test's log too: it expects them itself.
	for part: String in ["broken on purpose", "first error", "second error"]:
		expect_error(part)
	var run := TestSuite.run(PackedStringArray([FIXTURE]))
	assert_eq(run.test_count(), 3)
	var failed := run.failed()
	assert_eq(failed.size(), 2)
	assert_eq(failed[0].name, "test_expects_an_error_that_never_comes")
	assert_eq(
		failed[0].failures,
		PackedStringArray(['expected an error holding "never logged", none was logged'])
	)
	assert_eq(failed[1].name, "test_logs_more_than_it_expects")
	assert_eq(failed[1].failures.size(), 1)
	assert_has(failed[1].failures[0], "second error")
