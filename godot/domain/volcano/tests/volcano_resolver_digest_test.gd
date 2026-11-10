extends TestCase
## Not in the Dart file: 12 turns of raids and kraken waves on the games of
## GameFactory, as the Dart rules resolve them, read by a scratch script run
## with `dart run` on lib/domain. GameFactory.newGame(playerName: 'Nemo',
## mapSeed: seed, difficulty, factionCount, humanId: 'human'), armed as
## RaidDigests.arm_for_volcano says. Each turn t from 1 to 12, each player
## in order (index i) loses a siege of its kernel when t is 3 + i, makes
## (t × 7 + i × 3) % 11 noise, then RaidResolver.resolve and
## VolcanoResolver.resolve(player, t) with the game's difficulty and
## factions, both on one Random(seed) for the game, as the end of a turn
## does. Per player: each wave as "turn V|L kernel-level krakens dead
## wounded fight-turns", each announce as "turn +krakens@arrival"; then the
## volcano state, the kernel, the garrison and the raids won and lost. Last,
## the game's next nextInt(1000).

const DIGESTS: Dictionary[String, Dictionary] = {
	"solo-5": {
		"human": ["1 +3@2, 2 V 3 3 0 0 2, 2 +5@3, 3 +5@4, 4 V 3 5 1 1 3, 4 +5@5, 5 V 3 5 0 1 4, 5 +5@6, 6 V 3 5 0 1 4, 6 +5@7, 7 V 3 5 0 1 3, 7 +5@8, 8 V 3 5 0 2 3, 8 +5@9, 9 V 3 5 0 3 4, 9 +5@10, 10 V 3 5 0 1 4, 10 +5@11, 11 V 3 5 0 0 3, 11 +5@12, 12 V 3 5 1 1 4, 12 +5@13", "10 0 true 13 3 | 0 0 10 20 0 0 | 2 0"],
		"next": 299,
	},
	"hard-11-three": {
		"human": ["1 +3@2, 2 V 3 3 0 0 2, 2 +5@3, 3 +5@4, 4 V 3 5 0 0 3, 4 +5@5, 5 V 3 5 1 1 4, 5 +5@6, 6 V 3 5 0 0 4, 6 +5@7, 7 V 3 5 0 0 4, 7 +5@8, 8 V 3 5 0 0 4, 8 +5@9, 9 V 3 5 1 0 4, 9 +5@10, 10 V 3 5 1 1 4, 10 +5@11, 11 V 3 5 0 2 4, 11 +5@12, 12 V 3 5 0 3 3, 12 +5@13", "10 0 true 13 3 | 0 0 10 19 0 0 | 2 0"],
		"faction-currentNomads": ["1 +2@2, 2 L 2 2 3 1 7, 2 +2@3, 3 L 1 2 1 0 3", "0 2 false null 0 | 0 0 0 0 0 0 | 0 1"],
		"faction-murenaHorde": ["1 +2@2, 2 L 2 2 4 0 9, 2 +2@3, 3 L 1 2 0 0 3", "0 2 false null 0 | 0 0 0 0 0 0 | 0 1"],
		"faction-wreckPillagers": ["1 +2@2, 2 L 2 2 3 1 8, 2 +2@3, 3 L 1 2 1 0 3", "0 2 false null 0 | 0 0 0 0 0 0 | 1 0"],
		"next": 861,
	},
	"easy-24-two": {
		"human": ["1 +2@2, 2 V 3 2 0 0 2, 2 +4@3, 3 +4@4, 4 V 3 4 0 0 3, 4 +4@5, 5 V 3 4 0 0 3, 5 +4@6, 6 V 3 4 0 0 3, 6 +4@7, 7 V 3 4 0 1 3, 7 +4@8, 8 V 3 4 0 1 3, 8 +4@9, 9 V 3 4 0 0 3, 9 +4@10, 10 V 3 4 0 0 3, 10 +4@11, 11 V 3 4 0 0 3, 11 +4@12, 12 V 3 4 0 0 3, 12 +4@13", "10 0 true 13 3 | 0 0 12 20 0 0 | 2 0"],
		"faction-krakenFaithful": ["1 +1@2, 2 L 2 1 3 1 16, 2 +1@3, 3 L 1 1 1 0 5", "0 2 false null 0 | 0 0 0 0 0 0 | 0 1"],
		"faction-murenaHorde": ["1 +1@2, 2 L 2 1 4 0 16, 2 +1@3, 3 L 1 1 0 0 5", "0 2 false null 0 | 0 0 0 0 0 0 | 1 0"],
		"next": 673,
	},
}
## Name: [seed, difficulty, factions].
const GAMES: Dictionary[String, Array] = {
	"solo-5": [5, Difficulty.Value.NORMAL, 0],
	"hard-11-three": [11, Difficulty.Value.HARD, 3],
	"easy-24-two": [24, Difficulty.Value.EASY, 2],
}


func test_raids_and_kraken_waves_resolve_as_dart_resolves_them_on_new_games() -> void:
	for name: String in GAMES:
		var seed_: int = GAMES[name][0]
		var difficulty: Difficulty.Value = GAMES[name][1]
		var count: int = GAMES[name][2]
		var game := GameFactory.new_game("Nemo", seed_, difficulty, false, count, null, "human")
		RaidDigests.arm_for_volcano(game)
		var random := DartRandom.new(seed_)
		var events := {}
		for id: String in game.players:
			events[id] = PackedStringArray()
		for t: int in range(1, 13):
			var index := 0
			for player: Player in game.players.values():
				var log_: PackedStringArray = events[player.id]
				_end_turn(player, t, index, random, difficulty, game.factions().size(), log_)
				index += 1
		var expected: Dictionary = DIGESTS[name]
		for player: Player in game.players.values():
			var log_: PackedStringArray = events[player.id]
			var got := [", ".join(log_), RaidDigests.volcano_state(player)]
			assert_eq(got, expected[player.id], "%s %s" % [name, player.id])
		assert_eq(game.players.size() + 1, expected.size(), name)
		assert_eq(random.next_int(1000), expected["next"], name)


func _end_turn(
	player: Player, t: int, index: int, random: DartRandom, difficulty: Difficulty.Value,
	factions: int, log_: PackedStringArray,
) -> void:
	if t == 3 + index:
		player.raid_state.kernel_siege_lost_turn = t
	player.raid_state.add_noise((t * 7 + index * 3) % 11)
	var is_faction := player.id != "human"
	RaidResolver.resolve(player, t, random, difficulty, is_faction, factions)
	var o := VolcanoResolver.resolve(player, t, random, difficulty, is_faction, factions)
	if o.report != null:
		log_.append(RaidDigests.volcano_report(o.report))
	if o.announced != null:
		log_.append("%d +%d@%d" % [t, o.announced.unit_count, player.volcano_state.arrival_turn])
