class_name TestResult
extends RefCounted
## The outcome of one test: where it is, and what went wrong if anything.

var file: String
var name: String
var failures: PackedStringArray


func _init(test_file: String, test_name: String, test_failures: PackedStringArray) -> void:
	file = test_file
	name = test_name
	failures = test_failures


func passed() -> bool:
	return failures.is_empty()


## One line naming the test and all its failures.
func report_line() -> String:
	return "FAIL %s::%s: %s" % [file, name, "; ".join(failures)]
