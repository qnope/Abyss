class_name TestRunOptions
extends RefCounted
## The runner's command line arguments: the paths of the tests to run, and
## `--coverage-out=<file>`, where an instrumented copy writes its hits.

const COVERAGE_OUT := "--coverage-out="

var paths: PackedStringArray = PackedStringArray()
## Empty unless asked for.
var coverage_out: String = ""


func _init(arguments: PackedStringArray) -> void:
	for argument: String in arguments:
		if argument.begins_with(COVERAGE_OUT):
			coverage_out = argument.trim_prefix(COVERAGE_OUT)
		else:
			paths.append(argument)
