class_name TestFileRunner
extends RefCounted
## Runs the tests of one file, each on a fresh instance of the file's class,
## and turns its failed assertions and logged errors into results. A file that
## cannot run gives a single failed result named after the file.

const PREFIX := "test_"


static func run(path: String) -> Array[TestResult]:
	if not ResourceLoader.exists(path):
		return [_broken(path, "no such test file")]
	var error_log := _listen()
	var script := load(path) as GDScript
	OS.remove_logger(error_log)
	if script == null or not script.can_instantiate():
		return [_broken(path, "cannot load the script: %s" % "; ".join(error_log.errors()))]
	if not _is_test_case(script):
		return [_broken(path, "does not extend TestCase")]
	var results: Array[TestResult] = []
	for test_name: String in test_names(script):
		results.append(_run_test(script, path, test_name))
	return results


## The script's test methods, in the order they are declared.
static func test_names(script: GDScript) -> PackedStringArray:
	var names := PackedStringArray()
	for method: Dictionary in script.get_script_method_list():
		var method_name: String = method["name"]
		if method_name.begins_with(PREFIX) and not names.has(method_name):
			names.append(method_name)
	return names


static func _run_test(script: GDScript, path: String, test_name: String) -> TestResult:
	var error_log := _listen()
	var test: TestCase = script.new()
	var failures := PackedStringArray()
	if test != null:
		test.before_each()
		test.call(test_name)
		test.after_each()
		failures = test.failures()
	OS.remove_logger(error_log)
	failures.append_array(error_log.errors())
	if test == null and failures.is_empty():
		failures.append("cannot create the test case")
	return TestResult.new(path, test_name, failures)


static func _listen() -> TestErrorLog:
	var error_log := TestErrorLog.new()
	OS.add_logger(error_log)
	return error_log


static func _is_test_case(script: Script) -> bool:
	var base := script
	while base != null:
		if base == TestCase:
			return true
		base = base.get_base_script()
	return false


static func _broken(path: String, message: String) -> TestResult:
	return TestResult.new(path, "(file)", PackedStringArray([message]))
