class_name TestRun
extends RefCounted
## The results of a run of test files, and how long it took.

var results: Array[TestResult] = []
var elapsed_msec: int = 0


func test_count() -> int:
	return results.size()


func failed() -> Array[TestResult]:
	var failures: Array[TestResult] = []
	for result: TestResult in results:
		if not result.passed():
			failures.append(result)
	return failures


func failed_count() -> int:
	return failed().size()


## The process's exit code: 0 when every test passed, 1 otherwise.
func exit_code() -> int:
	return 0 if failed_count() == 0 else 1


func summary() -> String:
	return "%d tests, %d failed, in %d ms" % [test_count(), failed_count(), elapsed_msec]


## A line per failed test, then the summary.
func report_lines() -> PackedStringArray:
	var lines := PackedStringArray()
	for result: TestResult in failed():
		lines.append(result.report_line())
	lines.append(summary())
	return lines
