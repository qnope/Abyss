extends TestCase
## Not in the Dart files: the moves of the scripts played turn after turn on
## the games of GameFactory, each player developed between the turns
## (ScriptDigests), each line compared with what a scratch Dart script
## printed (ScriptHistories), to the last die of the game.

const GAMES := {
	"solo-3": [3, Difficulty.Value.NORMAL, 0],
	"hard-11-two": [11, Difficulty.Value.HARD, 2],
	"easy-24-three": [24, Difficulty.Value.EASY, 3],
}


func test_the_moves_give_what_the_dart_scripts_gave() -> void:
	for name: String in GAMES:
		var expected: Array = ScriptHistories.DIGESTS[name]
		var lines := _play(name)
		assert_eq(lines.size(), expected.size(), name)
		for k: int in mini(lines.size(), expected.size()):
			assert_eq(lines[k], expected[k], "%s line %d" % [name, k])


func _play(name: String) -> PackedStringArray:
	var spec: Array = GAMES[name]
	var seed_: int = spec[0]
	var difficulty: Difficulty.Value = spec[1]
	var count: int = spec[2]
	var game := GameFactory.new_game("Nemo", seed_, difficulty, false, count, null, "human")
	var random := DartRandom.new(seed_, false)
	var lines := PackedStringArray()
	for t: int in range(1, 15):
		game.turn = t
		var i := 0
		for p: Player in game.players.values():
			ScriptDigests.develop(game, p, t, i)
			var log_: Array[ScriptLogEntry] = []
			var turn := ScriptTurn.new(game, random, log_, p)
			ScriptDigests.play(turn, t, p.id != game.human_player_id)
			var entries := PackedStringArray()
			for entry: ScriptLogEntry in log_:
				entries.append(str(entry))
			lines.append("%d %s %s = %s" % [t, p.id, ", ".join(entries), ScriptDigests.state(game, p)])
			i += 1
		ExplorationResolver.resolve(game)
	lines.append("next %d" % random.next_int(1000))
	return lines
