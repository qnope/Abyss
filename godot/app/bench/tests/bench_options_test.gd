extends TestCase
## The bench asked for at launch, by the web page's address or the command
## line.


func test_reads_the_page_s_address() -> void:
	assert_eq(BenchOptions.of_query("?bench=1").seconds, BenchOptions.DEFAULT_SECONDS)
	assert_eq(BenchOptions.of_query("?lang=fr&bench=40").seconds, 40.0)
	assert_eq(BenchOptions.of_query("?bench").seconds, BenchOptions.DEFAULT_SECONDS)
	assert_eq(BenchOptions.of_query("?bench=0").seconds, 0.0)
	assert_eq(BenchOptions.of_query("").seconds, 0.0)
	assert_eq(BenchOptions.of_query("?benchmark=1").seconds, 0.0)


func test_reads_the_command_line() -> void:
	assert_eq(BenchOptions.of_args(PackedStringArray(["--bench"])).seconds, 20.0)
	assert_eq(BenchOptions.of_args(PackedStringArray(["x", "--bench=12"])).seconds, 12.0)
	assert_eq(BenchOptions.of_args(PackedStringArray(["--benchy"])).seconds, 0.0)


func test_runs_none_without_asking() -> void:
	assert_eq(BenchOptions.from_launch(false).seconds, 0.0, "the tests' command line")
	assert_eq(BenchOptions.from_launch(true).seconds, 0.0, "no page off the web")
	assert_eq(BenchOptions.from_launch().seconds, 0.0)


func test_reads_no_address_off_the_web() -> void:
	assert_eq(BenchOptions.web_query(), "")
