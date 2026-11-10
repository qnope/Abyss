extends TestCase
## Not in the Dart file: 24 turns of raids on the games of GameFactory, as
## the Dart rules resolve them, read by a scratch script run with `dart run`
## on lib/domain. GameFactory.newGame(playerName: 'Nemo', mapSeed: seed,
## difficulty, factionCount, humanId: 'human'); the human gets 15
## harpoonists, 4 guardians, a Citadel 2 and a headquarters 3, each faction
## 8 harpoonists. Each turn t from 1 to 24, each player in order (index i)
## makes (t × 7 + i × 3) % 11 noise, then RaidResolver.resolve(player, t)
## with the game's difficulty and factions and one Random(seed) for the
## game. Per player: each raid as "turn V|L dead wounded loot pillaged
## fight-turns" (sums), each announce as "turn wave@arrival"; then the raid
## state, the stocks and the units on the base. Last, the game's next
## nextInt(1000). The history entries the players hold, counted after each
## turn, are RaidHistories.RAIDS.

const DIGESTS: Dictionary[String, Dictionary] = {
	"solo-3": {
		"human": ["5 medium/armoured/5/swarm/21@10, 10 V 2 2 51 0 9, 10 easy/swarm/42/hunter/11@12, 12 V 0 4 50 0 3, 15 medium/armoured/7/hunter/8@17, 17 L 12 5 0 225 4, 20 medium/armoured/9/swarm/42@22, 22 L 3 2 0 156 2", "26 192 2 2 2 false | 49 177 94 49 6 | 0 2 0 0 0 0"],
		"next": 402,
	},
	"hard-11-three": {
		"human": ["5 medium/colossus/1/armoured/4@10, 10 V 2 2 51 0 9, 10 easy/swarm/42/hunter/11@12, 12 V 7 2 50 0 4, 15 medium/colossus/1/armoured/7@17, 17 L 9 1 0 225 6, 20 medium/swarm/42/colossus/2@22, 22 L 1 0 0 156 1", "26 192 2 2 2 false | 49 177 94 49 6 | 0 0 0 0 0 0"],
		"faction-currentNomads": ["5 easy/armoured/4/hunter/4@10, 10 V 5 1 0 0 15, 11 easy/swarm/36/armoured/8@13, 13 L 3 0 0 195 1, 16 medium/hunter/7/colossus/1@18, 18 L 0 0 0 136 0, 22 medium/colossus/2/armoured/8@24, 24 L 0 0 0 94 0", "22 198 3 1 3 false | 35 103 52 35 5 | 0 0 0 0 0 0"],
		"faction-murenaHorde": ["5 easy/armoured/4/hunter/4@10, 10 L 7 1 0 195 10, 11 easy/hunter/9/swarm/36@13, 13 L 0 1 0 136 1, 16 medium/armoured/6/colossus/1@18, 18 L 0 1 0 94 1, 22 medium/armoured/8/swarm/36@24, 24 L 1 0 0 65 1", "17 193 4 0 4 false | 25 73 37 25 5 | 0 0 0 0 0 0"],
		"faction-wreckPillagers": ["6 easy/hunter/4/swarm/15@10, 10 V 1 2 0 0 3, 11 easy/swarm/36/hunter/9@13, 13 L 7 0 0 195 1, 17 medium/colossus/1/hunter/6@19, 19 L 0 0 0 136 0, 22 medium/hunter/9/colossus/2@24, 24 L 0 0 0 94 0", "12 188 3 1 3 false | 35 103 52 35 5 | 0 0 0 0 0 0"],
		"next": 412,
	},
	"easy-24-two": {
		"human": ["5 easy/armoured/9/hunter/10@10, 10 V 1 2 50 0 9, 10 easy/swarm/39/hunter/9@12, 12 V 1 1 50 0 3, 15 medium/hunter/7/colossus/1@17, 17 V 0 2 51 0 5, 20 medium/colossus/2/swarm/36@22, 22 L 14 3 0 240 12", "26 192 1 3 1 false | 70 273 147 70 6 | 0 3 0 0 0 0"],
		"faction-krakenFaithful": ["5 easy/swarm/15/hunter/4@10, 10 V 1 3 0 0 3, 11 easy/hunter/8/swarm/30@13, 13 L 4 3 0 195 2, 16 medium/armoured/5/swarm/21@18, 18 L 3 0 0 136 1, 22 medium/swarm/30/hunter/8@24, 24 L 0 0 0 94 0", "22 198 3 1 3 false | 35 103 52 35 5 | 0 0 0 0 0 0"],
		"faction-murenaHorde": ["5 easy/hunter/4/armoured/2@10, 10 V 1 1 0 0 6, 11 easy/hunter/8/armoured/7@13, 13 L 7 0 0 195 2, 16 easy/hunter/12/armoured/9@18, 18 L 0 0 0 136 0, 22 medium/armoured/7/hunter/8@24, 24 L 0 0 0 94 0", "17 193 3 1 3 false | 35 103 52 35 5 | 0 0 0 0 0 0"],
		"next": 280,
	},
	"normal-7-one": {
		"human": ["5 medium/armoured/5/colossus/1@10, 10 L 14 5 0 195 17, 10 easy/swarm/42/armoured/9@12, 12 L 4 1 0 136 3, 15 medium/armoured/7/swarm/30@17, 17 L 1 0 0 94 1, 20 medium/hunter/11/swarm/39@22, 22 L 0 0 0 65 1", "26 192 4 0 4 false | 25 73 37 25 5 | 0 0 0 0 0 0"],
		"faction-anglerCult": ["5 easy/armoured/4/hunter/4@10, 10 L 6 2 0 195 5, 11 easy/hunter/8/swarm/33@13, 13 L 2 0 0 136 1, 16 medium/swarm/27/colossus/1@18, 18 L 0 0 0 94 0, 22 medium/armoured/7/swarm/33@24, 24 L 0 0 0 65 0", "22 198 4 0 4 false | 25 73 37 25 5 | 0 0 0 0 0 0"],
		"next": 521,
	},
}
## Name: [seed, difficulty, factions].
const GAMES: Dictionary[String, Array] = {
	"solo-3": [3, Difficulty.Value.NORMAL, 0],
	"hard-11-three": [11, Difficulty.Value.HARD, 3],
	"easy-24-two": [24, Difficulty.Value.EASY, 2],
	"normal-7-one": [7, Difficulty.Value.NORMAL, 1],
}


func test_raids_resolve_as_dart_resolves_them_on_new_games() -> void:
	for name: String in GAMES:
		var seed_: int = GAMES[name][0]
		var difficulty: Difficulty.Value = GAMES[name][1]
		var count: int = GAMES[name][2]
		var game := GameFactory.new_game("Nemo", seed_, difficulty, false, count, null, "human")
		RaidDigests.arm_for_raids(game)
		var random := DartRandom.new(seed_)
		var events := {}
		var sizes := {}
		for id: String in game.players:
			events[id] = PackedStringArray()
			sizes[id] = PackedStringArray()
		for t: int in range(1, 25):
			var index := 0
			for player: Player in game.players.values():
				player.raid_state.add_noise((t * 7 + index * 3) % 11)
				var o := RaidResolver.resolve(
					player, t, random, difficulty, player.id != "human", game.factions().size()
				)
				var log_: PackedStringArray = events[player.id]
				if o.report != null:
					log_.append(RaidDigests.report(o.report))
				if o.announced != null:
					log_.append("%d %s@%d" % [t, RaidDigests.wave(o.announced), o.announced_turn])
				index += 1
			HistoryDigests.count_entries(game, sizes)
		var expected: Dictionary = DIGESTS[name]
		for player: Player in game.players.values():
			var log_: PackedStringArray = events[player.id]
			var got := [", ".join(log_), RaidDigests.raid_state(player)]
			assert_eq(got, expected[player.id], "%s %s" % [name, player.id])
			var held: PackedStringArray = sizes[player.id]
			var history: Array = RaidHistories.RAIDS[name][player.id]
			assert_eq(HistoryDigests.history(player, held), history, "%s %s" % [name, player.id])
		assert_eq(game.players.size() + 1, expected.size(), name)
		assert_eq(random.next_int(1000), expected["next"], name)
