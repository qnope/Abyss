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


func test_gives_the_run_ten_minutes_by_default() -> void:
	var options := TestRunOptions.new(PackedStringArray(["app"]))
	assert_eq(options.timeout_seconds, 600.0)


func test_reads_how_long_the_run_may_take() -> void:
	var options := TestRunOptions.new(PackedStringArray(["--timeout=2.5", "app"]))
	assert_eq(options.paths, PackedStringArray(["app"]))
	assert_eq(options.timeout_seconds, 2.5)
