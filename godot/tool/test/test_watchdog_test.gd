extends TestCase
## TestWatchdog ends a run that does not finish in time. It acts on a whole
## process, so each test runs a fixture runner in a child Godot.

const FIXTURES := "res://tool/test/fixtures/"


func test_quits_with_1_a_run_that_never_finishes() -> void:
	var result := _run_runner("stalled_runner.gd")
	assert_eq(result.code, 1, result.output)
	assert_has(result.output, "The test run did not finish within 0.2 s.")


func test_lets_a_stopped_run_end_as_it_wants() -> void:
	var result := _run_runner("stopped_runner.gd")
	assert_eq(result.code, 0, result.output)
	assert_false(result.output.contains("did not finish"), result.output)


func _run_runner(file_name: String) -> CommandResult:
	var arguments := PackedStringArray([
		"--headless", "--path", ProjectSettings.globalize_path("res://"),
		"--script", FIXTURES + file_name,
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
