extends TestCase
## Not in the Dart files: 24 turns of random events on the games of
## GameFactory, as the Dart rules resolve them, read by a scratch script run
## with `dart run` on lib/domain. GameFactory.newGame(playerName: 'Nemo',
## mapSeed: seed, difficulty, factionCount, humanId: 'human'), armed as
## RaidDigests.arm_for_raids says. Each turn t from 1 to 24, game.turn = t,
## then each player in order (index i) makes (t × 7 + i × 3) % 11 noise,
## chooses as EventDigests.choose says, and EventResolver.resolve(game,
## player, t) runs on one Random(seed) for the game. Per player: each choice,
## each predators fought as "turn P report", each event defaulted as
## "turn -type", each wreck ending as "turn W searched until", each draw as
## "turn +type" and what it left; then the event state, the raid state, the
## stocks and the units on the base. Last, the game's next nextInt(1000).
## The history entries, counted after each turn, are EventHistories.EVENTS.

const DIGESTS: Dictionary[String, Dictionary] = {
	"solo-3": {
		"human": ["8 +coldCurrent, 9 NcoldCurrent, 15 +storm, 23 +caravan coral>algae, 24 -caravan", "29 caravan 3 null null null false null,null null | 110 120 0 0 | 100 300 150 100 5 | 0 15 4 0 0 0"],
		"next": 8,
	},
	"hard-11-three": {
		"human": ["7 +caravan coral>algae, 8 -caravan, 13 +warmCurrent, 14 YwarmCurrent, 20 +predators easy/armoured/7/swarm/27, 21 Ypredators, 21 P V easy/armoured/7/swarm/27 0 0 50 0 6", "28 predators 3 null null null false null,null null | 129 129 0 0 | 100 330 170 100 5 | 0 15 4 0 0 0"],
		"faction-currentNomads": ["8 +storm, 15 +caravan coral>algae, 16 Ncaravan, 22 +survivors 4, 23 -survivors", "27 survivors 3 null null null false null,null null | 116 126 0 0 | 100 300 150 100 5 | 0 8 0 0 0 0"],
		"faction-murenaHorde": ["6 +warmCurrent, 7 NwarmCurrent, 12 +coldCurrent, 13 NcoldCurrent, 19 +survivors 3, 20 Ysurvivors", "27 survivors 3 null null null false null,null null | 121 121 0 0 | 100 300 150 100 5 | 0 11 0 0 0 0"],
		"faction-wreckPillagers": ["5 +warmCurrent, 6 NwarmCurrent, 11 +storm, 17 +survivors 3, 18 Nsurvivors, 24 +wreck@9,20", "30 wreck 4 null null null false 9,20 29 | 106 116 0 0 | 100 300 150 100 5 | 0 8 0 0 0 0"],
		"next": 819,
	},
	"easy-24-two": {
		"human": ["5 +wreck@13,8, 10 W false 10, 11 +warmCurrent, 12 -warmCurrent, 16 +wreck@7,9, 21 W false 21, 22 +survivors 4, 23 Nsurvivors", "27 survivors 4 null null null false null,null null | 120 120 0 0 | 100 300 150 100 5 | 0 15 4 0 0 0"],
		"faction-krakenFaithful": ["7 +storm, 12 +warmCurrent, 13 YwarmCurrent, 17 +predators easy/hunter/6/armoured/4, 18 Ypredators, 18 P L easy/hunter/6/armoured/4 6 2 0 195 4, 24 +storm", "32 storm 4 null storm 26 false null,null null | 115 135 0 0 | 70 210 105 70 5 | 0 2 0 0 0 0"],
		"faction-murenaHorde": ["7 +storm, 12 +coldCurrent, 13 NcoldCurrent, 20 +storm", "26 storm 3 null null null false null,null null | 101 121 0 0 | 100 300 150 100 5 | 0 8 0 0 0 0"],
		"next": 673,
	},
	"normal-7-one": {
		"human": ["5 +storm, 11 +caravan coral>algae, 12 -caravan, 19 +survivors 3, 20 -survivors", "25 survivors 3 null null null false null,null null | 110 120 0 0 | 100 300 150 100 5 | 0 15 4 0 0 0"],
		"faction-anglerCult": ["6 +warmCurrent, 7 -warmCurrent, 13 +survivors 3, 14 Nsurvivors, 18 +wreck@9,5, 23 W false 23, 23 +storm", "29 storm 4 null storm 25 false null,null null | 116 126 0 0 | 100 300 150 100 5 | 0 8 0 0 0 0"],
		"next": 584,
	},
}
## Name: [seed, difficulty, factions].
const GAMES: Dictionary[String, Array] = {
	"solo-3": [3, Difficulty.Value.NORMAL, 0],
	"hard-11-three": [11, Difficulty.Value.HARD, 3],
	"easy-24-two": [24, Difficulty.Value.EASY, 2],
	"normal-7-one": [7, Difficulty.Value.NORMAL, 1],
}


func test_events_resolve_as_dart_resolves_them_on_new_games() -> void:
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
			game.turn = t
			var index := 0
			for player: Player in game.players.values():
				var log_: PackedStringArray = events[player.id]
				_end_turn(game, player, t, index, random, log_)
				index += 1
			HistoryDigests.count_entries(game, sizes)
		var expected: Dictionary = DIGESTS[name]
		for player: Player in game.players.values():
			var log_: PackedStringArray = events[player.id]
			var got := [", ".join(log_), EventDigests.state(player)]
			assert_eq(got, expected[player.id], "%s %s" % [name, player.id])
			var held: PackedStringArray = sizes[player.id]
			var history: Array = EventHistories.EVENTS[name][player.id]
			assert_eq(HistoryDigests.history(player, held), history, "%s %s" % [name, player.id])
		assert_eq(game.players.size() + 1, expected.size(), name)
		assert_eq(random.next_int(1000), expected["next"], name)


func _end_turn(game: Game, player: Player, t: int, index: int, random: DartRandom, log_: PackedStringArray) -> void:
	player.raid_state.add_noise((t * 7 + index * 3) % 11)
	var choice := EventDigests.choose(game, player, t, index)
	if not choice.is_empty():
		log_.append(choice)
	var o := EventResolver.resolve(game, player, t, random)
	if o.predators != null:
		log_.append("%d P %s" % [t, EventDigests.report(o.predators)])
	if o.defaulted != null:
		log_.append("%d -%s" % [t, EventDigests.name_of(o.defaulted)])
	if o.wreck != null:
		log_.append("%d W %s %d" % [t, o.wreck.searched, o.wreck.until_turn])
	if o.drawn != null:
		log_.append("%d +%s%s" % [t, EventDigests.name_of(o.drawn), EventDigests.drawn(player)])
