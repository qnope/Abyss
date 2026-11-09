class_name TestCoverageDump
extends RefCounted
## Hands the hits to the CoverageProbe class that tool/godot_coverage.py adds
## to its instrumented copy of the project. The project itself has no such
## class, so the runner looks it up by name rather than naming it.

const PROBE_CLASS := &"CoverageProbe"


## Calls CoverageProbe.dump(path); returns what went wrong, or "".
static func write(
	path: String, classes: Array[Dictionary] = ProjectSettings.get_global_class_list()
) -> String:
	for entry: Dictionary in classes:
		if entry["class"] == PROBE_CLASS:
			var script_path: String = entry["path"]
			var probe := load(script_path) as GDScript
			var error: Error = probe.call("dump", path)
			if error != OK:
				return "Cannot write the coverage to %s: %s" % [path, error_string(error)]
			return ""
	return "No %s class: run the tests through tool/godot_coverage.py" % PROBE_CLASS
