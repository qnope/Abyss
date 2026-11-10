class_name TestRunOptions
extends RefCounted
## The runner's command line arguments: the paths of the tests to run,
## `--coverage-out=<file>`, where an instrumented copy writes its hits, and
## `--timeout=<seconds>`, after which TestWatchdog ends an unfinished run.

const COVERAGE_OUT := "--coverage-out="
const TIMEOUT := "--timeout="

var paths: PackedStringArray = PackedStringArray()
## Empty unless asked for.
var coverage_out: String = ""
var timeout_seconds: float = 600.0


func _init(arguments: PackedStringArray) -> void:
	for argument: String in arguments:
		if argument.begins_with(COVERAGE_OUT):
			coverage_out = argument.trim_prefix(COVERAGE_OUT)
		elif argument.begins_with(TIMEOUT):
			timeout_seconds = argument.trim_prefix(TIMEOUT).to_float()
		else:
			paths.append(argument)
