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


func test_measures_the_base_unless_the_map_is_asked_for() -> void:
	assert_eq(BenchOptions.of_query("?bench=1").scene, BenchOptions.BASE)
	assert_eq(BenchOptions.of_query("?bench=1&scene=base").scene, BenchOptions.BASE)
	assert_eq(BenchOptions.of_query("?bench=1&scene=nothing").scene, BenchOptions.BASE)
	var map := BenchOptions.of_query("?scene=map&bench=30&level=2")
	assert_eq(map.scene, BenchOptions.MAP)
	assert_eq(map.level, 2)
	assert_eq(map.seconds, 30.0)
	assert_eq(BenchOptions.of_query("?bench=1&scene=map").level, 1, "the first level by default")
	assert_eq(BenchOptions.of_query("?bench=1&scene=map&level=0").level, 1, "never under the first")
	assert_eq(BenchOptions.of_query("?scene=map&level=2").seconds, 0.0, "no bench unless asked")


func test_reads_the_scene_from_the_command_line() -> void:
	var map := BenchOptions.of_args(PackedStringArray(["--bench=12", "--bench-scene=map", "--bench-level=3"]))
	assert_eq(map.scene, BenchOptions.MAP)
	assert_eq(map.level, 3)
	assert_eq(map.seconds, 12.0)
	assert_eq(BenchOptions.of_args(PackedStringArray(["--bench"])).scene, BenchOptions.BASE)


func test_measures_the_game_s_actions_when_asked() -> void:
	var game := BenchOptions.of_query("?bench=20&scene=game")
	assert_eq(game.scene, BenchOptions.GAME)
	assert_eq(game.seconds, 20.0)
	var args := BenchOptions.of_args(PackedStringArray(["--bench", "--bench-scene=game"]))
	assert_eq(args.scene, BenchOptions.GAME)
	assert_eq(args.seconds, BenchOptions.DEFAULT_SECONDS)
	assert_eq(BenchOptions.of_query("?scene=game").seconds, 0.0, "no bench unless asked")


func test_runs_none_without_asking() -> void:
	assert_eq(BenchOptions.from_launch(false).seconds, 0.0, "the tests' command line")
	assert_eq(BenchOptions.from_launch(true).seconds, 0.0, "no page off the web")
	assert_eq(BenchOptions.from_launch().seconds, 0.0)


func test_reads_no_address_off_the_web() -> void:
	assert_eq(BenchOptions.web_query(), "")
