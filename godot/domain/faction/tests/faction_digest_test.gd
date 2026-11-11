extends TestCase
## Not in the Dart files: the brains of the factions played turn after turn
## on the games of GameFactory, each player developed between the turns
## (FactionDigests), then one turn of FactionTurns; each line compared with
## what a scratch Dart script printed (FactionHistories*), the actions, their
## results, the stocks, the wars, the sieges and the next die.

const TURNS := 18
const Personality := FactionPersonality.Value


func test_the_five_first_personalities_play_as_in_dart() -> void:
	var game := GameFactory.new_game("Nemo", 7, Difficulty.Value.NORMAL, false, 0, [
		Personality.WRECK_PILLAGERS, Personality.PEARL_ORDER, Personality.ANGLER_CULT,
		Personality.MURENA_HORDE, Personality.SIPHONOPHORE_GUILD,
	] as Array[Personality], "human")
	_compare(FactionDigests.play(game, 7, TURNS), FactionHistoriesFive7.LINES, "five-7")


func test_the_five_last_personalities_play_as_in_dart() -> void:
	var game := GameFactory.new_game("Nemo", 11, Difficulty.Value.HARD, false, 0, [
		Personality.SILENCE_MONKS, Personality.CURRENT_NOMADS, Personality.PYROSOME_HIVE,
		Personality.MAGMA_SMITHS, Personality.KRAKEN_FAITHFUL,
	] as Array[Personality], "human")
	_compare(FactionDigests.play(game, 11, TURNS), FactionHistoriesFive11.LINES, "five-11-hard")


func test_three_factions_drawn_play_as_in_dart_on_easy() -> void:
	var game := GameFactory.new_game("Nemo", 24, Difficulty.Value.EASY, false, 3, null, "human")
	_compare(FactionDigests.play(game, 24, TURNS), FactionHistoriesEasy24.LINES, "easy-24-three")


func _compare(lines: PackedStringArray, expected: Array[String], name: String) -> void:
	assert_eq(lines.size(), expected.size(), name)
	for k: int in mini(lines.size(), expected.size()):
		assert_eq(lines[k], expected[k], "%s line %d" % [name, k])
		if lines[k] != expected[k]:
			return
