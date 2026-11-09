extends TestCase
## Runs the command itself in a child Godot, for what only a process shows:
## its output, its exit code, and a script error that does not stop the run.

const FIXTURES := "res://tool/test/fixtures/"


func test_exits_with_0_when_every_test_passes() -> void:
	var result := _run_command(FIXTURES + "passing_test.gd")
	assert_eq(result.code, 0, result.output)
	assert_has(result.output, "3 tests, 0 failed, in ")


func test_exits_with_1_and_names_the_failures() -> void:
	var result := _run_command(FIXTURES + "failing_test.gd")
	assert_eq(result.code, 1, result.output)
	assert_has(result.output, "FAIL %sfailing_test.gd::test_adds_wrongly: " % FIXTURES)
	assert_has(result.output, "3 tests, 2 failed, in ")


func test_fails_a_test_that_hits_a_script_error_and_goes_on() -> void:
	var result := _run_command(FIXTURES + "script_error_test.gd")
	assert_eq(result.code, 1, result.output)
	assert_has(result.output, "::test_calls_a_method_on_null: ")
	assert_has(result.output, "Nonexistent function 'free' in base 'Nil'")
	assert_has(result.output, "2 tests, 1 failed, in ")


func _run_command(path: String) -> CommandResult:
	var arguments := PackedStringArray([
		"--headless", "--path", ProjectSettings.globalize_path("res://"),
		"--script", "res://tool/test/run_tests.gd", "--", path,
	])
	var output: Array = []
	var code := OS.execute(OS.get_executable_path(), arguments, output, true)
	return CommandResult.new(code, "".join(PackedStringArray(output)))


class CommandResult:
	var code: int
	var output: String

	func _init(exit_code: int, text: String) -> void:
		code = exit_code
		output = text
