extends TestCase
## TestRunOptions reads the runner's command line arguments.


func test_keeps_the_paths_in_order() -> void:
	var options := TestRunOptions.new(PackedStringArray(["app", "res://domain"]))
	assert_eq(options.paths, PackedStringArray(["app", "res://domain"]))
	assert_eq(options.coverage_out, "")


func test_reads_where_to_write_the_coverage() -> void:
	var options := TestRunOptions.new(
		PackedStringArray(["app", "--coverage-out=/tmp/hits.txt", "domain"])
	)
	assert_eq(options.paths, PackedStringArray(["app", "domain"]))
	assert_eq(options.coverage_out, "/tmp/hits.txt")
