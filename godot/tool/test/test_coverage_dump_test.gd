extends TestCase
## TestCoverageDump hands the hits to the CoverageProbe class that only an
## instrumented copy of the project has, a stub standing for it here.

const STUB_PATH := "res://tool/test/fixtures/coverage_probe_stub.gd"
const Stub := preload(STUB_PATH)


func before_each() -> void:
	Stub.dumped_to = ""


func test_calls_the_probe_class_dump_with_the_path() -> void:
	assert_eq(TestCoverageDump.write("/tmp/hits.txt", _classes(&"CoverageProbe")), "")
	assert_eq(Stub.dumped_to, "/tmp/hits.txt")


func test_tells_when_the_dump_fails() -> void:
	assert_eq(
		TestCoverageDump.write(Stub.UNWRITABLE, _classes(&"CoverageProbe")),
		"Cannot write the coverage to %s: Can't write file" % Stub.UNWRITABLE
	)


func test_tells_when_the_project_is_not_instrumented() -> void:
	var message := "No CoverageProbe class: run the tests through tool/godot_coverage.py"
	assert_eq(TestCoverageDump.write("/tmp/hits.txt", _classes(&"Other")), message)
	assert_eq(Stub.dumped_to, "")


func _classes(name: StringName) -> Array[Dictionary]:
	return [{"class": name, "path": STUB_PATH, "base": &"RefCounted"}]
