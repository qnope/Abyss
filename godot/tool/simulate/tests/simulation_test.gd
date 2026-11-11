extends TestCase
## The simulator's options and errors, and two of the outputs of
## reference/simulations/ played in this process (tool/simulations.py
## plays them all through tool/godot_simulate.sh).


func test_options_are_read_as_dart_reads_them() -> void:
	var options := SimulateOptions.new(["left", "--json", "--games", "3", "--verbose", "--seed", "-2"])

	assert_eq(options.values, {"json": "", "games": "3", "verbose": "", "seed": "-2"})
	assert_eq(options.whole("games", 20), 3)
	assert_eq(options.whole("seed", 1), -2)
	assert_eq(options.whole("turns", 60), 60)
	assert_eq(options.text("strategy", "balanced"), "balanced")
	assert_eq(options.error, "")


func test_a_number_dart_would_throw_on_is_an_error() -> void:
	var options := SimulateOptions.new(["--turns", "abc", "--army", "x"])

	assert_eq(options.whole("turns", 60), 60)
	assert_eq(options.decimal("army", 1.0), 1.0)
	assert_eq(options.error, "--turns: not a whole number: abc")


func test_a_decimal_and_a_difficulty() -> void:
	var options := SimulateOptions.new(["--army", "1.2", "--difficulty", "hard"])

	assert_eq(options.decimal("army", 1.0), 1.2)
	assert_eq(options.decimal("stretch", 1.0), 1.0)
	assert_eq(options.difficulty(), Difficulty.Value.HARD)
	assert_eq(SimulateOptions.new([]).difficulty(), Difficulty.Value.NORMAL)
	var wrong := SimulateOptions.new(["--difficulty", "brutal", "--army", "x"])
	assert_eq(wrong.difficulty(), Difficulty.Value.NORMAL)
	assert_eq(wrong.decimal("army", 1.0), 1.0)
	assert_eq(wrong.error, "--difficulty: no difficulty named brutal")


func test_the_variant_of_a_replay() -> void:
	var variant := SimulateOptions.new([
		"--new-map", "--army", "1.5", "--jitter", "2", "--stretch", "1.25", "--patience", "3", "--defends",
	]).variant()

	assert_eq(variant.label(), "autre carte, mêmes dés, armée ×1.5, retard 0-2, tempo ×1.25, défense prudente")
	assert_eq(variant.patience, 3)
	assert_true(SimulateOptions.new([]).variant().is_exact())


func test_an_unknown_strategy_plays_nothing() -> void:
	expect_error("Stratégie inconnue : nope")

	var simulation := Simulation.new(["--strategy", "nope"], ReferenceFiles.repo_root())

	assert_eq(simulation.error, "no script to play: see the errors above")
	assert_eq(simulation.output, "")


func test_a_file_that_is_not_there_plays_nothing() -> void:
	var simulation := Simulation.new(["--replay", "nope.json"], ReferenceFiles.repo_root())

	assert_eq(simulation.error, "Cannot open file, path = 'nope.json'")
	assert_eq(simulation.output, "")


func test_a_bad_option_plays_nothing() -> void:
	var simulation := Simulation.new(["--games", "two"], ReferenceFiles.repo_root())

	assert_eq(simulation.error, "--games: not a whole number: two")


func test_prints_what_dart_printed() -> void:
	for name: String in ["balanced", "no-game"]:
		var simulation := Simulation.new(_options_of(name), ReferenceFiles.repo_root())

		assert_eq(simulation.output, ReferenceFiles.text_of("reference/simulations/%s.txt" % name), name)


func _options_of(name: String) -> PackedStringArray:
	for line in ReferenceFiles.text_of("reference/simulations/cases.txt").split("\n"):
		if line.begins_with(name + ":"):
			return line.substr(name.length() + 1).split(" ", false)
	return []
