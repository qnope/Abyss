extends TestCase
## Not in the Dart files: whole games of GameFactory against the factions,
## the human played by a script as ScriptRunner.runOn does and each turn
## ended by EndTurnAction, the factions playing first (TurnDigests); each
## line compared with what a scratch Dart script printed (TurnHistories*):
## the moves, the TurnResult, the TurnEndEntry, the game, the next die and
## the state of every player.

const Personality := FactionPersonality.Value


func test_a_balanced_human_against_two_factions_plays_as_in_dart() -> void:
	var game := GameFactory.new_game("Nemo", 7, Difficulty.Value.NORMAL, false, 2, null, "human")
	_compare(TurnDigests.play(game, BalancedStrategy.new(), 7, 30), TurnHistoriesBalanced7.LINES, "balanced-7")


func test_a_conquering_human_against_three_factions_plays_as_in_dart_on_hard() -> void:
	var game := GameFactory.new_game("Nemo", 11, Difficulty.Value.HARD, false, 0, [
		Personality.MURENA_HORDE, Personality.KRAKEN_FAITHFUL, Personality.MAGMA_SMITHS,
	] as Array[Personality], "human")
	var lines := TurnDigests.play(game, ConquestStrategy.new(), 11, 30)
	_compare(lines, TurnHistoriesConquest11.LINES, "conquest-11-hard")


func test_a_thrifty_human_falls_to_the_raids_as_in_dart_on_easy() -> void:
	var game := GameFactory.new_game("Nemo", 24, Difficulty.Value.EASY, false, 2, null, "human")
	_compare(TurnDigests.play(game, EconomyStrategy.new(), 24, 40), TurnHistoriesEconomy24.LINES, "economy-24-easy")


func test_an_idle_human_and_two_factions_play_as_in_dart() -> void:
	var game := GameFactory.new_game("Nemo", 5, Difficulty.Value.NORMAL, false, 0, [
		Personality.MURENA_HORDE, Personality.ANGLER_CULT,
	] as Array[Personality], "human")
	_compare(TurnDigests.play(game, IdleScript.new(), 5, 30), TurnHistoriesIdle5.LINES, "idle-5")


func _compare(lines: PackedStringArray, expected: Array[String], name: String) -> void:
	assert_eq(lines.size(), expected.size(), name)
	for k: int in mini(lines.size(), expected.size()):
		assert_eq(lines[k], expected[k], "%s line %d" % [name, k])
		if lines[k] != expected[k]:
			return
