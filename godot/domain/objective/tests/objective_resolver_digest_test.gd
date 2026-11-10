extends TestCase
## Not in the Dart file: 20 turns of objectives, events and tips on the games
## of GameFactory, as the Dart rules resolve them, read by a scratch script
## run with `dart run` on lib/domain. GameFactory.newGame(playerName: 'Nemo',
## mapSeed: seed, difficulty, factionCount, humanId: 'human'). Each turn t
## from 1 to 20, game.turn = t, then each player in order (index i) is
## developed as ObjectiveDigests.develop says, makes (t × 7 + i × 3) % 11
## noise, chooses as EventDigests.choose says, and EventResolver.resolve(game,
## player, t) runs on one Random(seed) for the game. Per player: each choice,
## each objective of an event ended (TemporaryObjectives.endedBy), each
## objective completed by ObjectiveResolver.resolve with what it credited,
## the current objective when it changes, the objectives of the events under
## way (activeOf) and the tips newly applying; then the stocks. Last,
## the game's next nextInt(1000).

const DIGESTS: Dictionary[String, Dictionary] = {
	"solo-3": {
		"human": ["1 +algaeFarm coral:30 ore:20, 1 >hqLevel1, 2 !noiseGauge, 3 +mines coral:30 ore:20, 4 +solarPanel coral:30 ore:20, 4 +explore coral:30 ore:20, 4 !techChoice chestAndRuins, 6 +barracksAndScouts coral:30 ore:20, 6 +laboratoryAndResearch coral:30 ore:20, 6 !raidAnnounced, 7 +hqLevel1 coral:30 ore:20, 7 >hqLevel2, 8 +solarPanelLevel2 coral:30 ore:20, 8 +firstRaid coral:30 ore:20, 8 !raidReport events coldCurrent abyssListens, 9 NcoldCurrent, 9 +coralCitadel coral:60 ore:40 algae:40, 9 !ancients, 10 +takeLair coral:60 ore:40 algae:40, 10 +descentModule coral:100 ore:70 algae:60, 10 !descent, 11 +pressureCapsule coral:150 ore:100 algae:90, 11 !factionAttack, 12 +kernelLevel1 coral:200 ore:140 algae:120, 12 !admiral awakening, 13 +hqLevel2 coral:30 ore:20, 13 >hqLevel5, 14 +takeFaille coral:100 ore:70 algae:60, 14 !postDefence, 15 !lastChance storm, 16 !lair monsterFamilies forgeTowers", "510 1270 810 100 5"],
		"next": 324,
	},
	"hard-11-three": {
		"human": ["1 +algaeFarm coral:30 ore:20, 1 >hqLevel1, 2 !noiseGauge, 3 +mines coral:30 ore:20, 4 +solarPanel coral:30 ore:20, 4 +explore coral:30 ore:20, 4 !techChoice lair monsterFamilies chestAndRuins, 6 +barracksAndScouts coral:30 ore:20, 6 +laboratoryAndResearch coral:30 ore:20, 6 !raidAnnounced, 7 +hqLevel1 coral:30 ore:20, 7 >hqLevel2, 7 !events caravan, 8 +solarPanelLevel2 coral:30 ore:20, 8 +firstRaid coral:30 ore:20, 8 !raidReport abyssListens, 9 +coralCitadel coral:60 ore:40 algae:40, 9 !ancients, 10 +takeLair coral:60 ore:40 algae:40, 10 +descentModule coral:100 ore:70 algae:60, 10 !descent, 11 +pressureCapsule coral:150 ore:100 algae:90, 11 !factionAttack, 12 +kernelLevel1 coral:200 ore:140 algae:120, 12 !admiral awakening, 13 +hqLevel2 coral:30 ore:20, 13 >hqLevel5, 13 !warmCurrent, 14 YwarmCurrent, 14 +takeFaille coral:100 ore:70 algae:60, 14 !postDefence, 15 !lastChance, 16 +descendLevel2 coral:100 ore:70 algae:60, 16 !forgeTowers, 18 +takeKernel coral:200 ore:140 algae:120, 18 !kernelGarrison, 20 !predators", "690 1570 1020 100 5"],
		"faction-currentNomads": ["1 >hqLevel1, 1 !noiseGauge transitionBase, 2 +mines coral:30 ore:20, 3 +solarPanel coral:30 ore:20, 5 +barracksAndScouts coral:30 ore:20, 5 +explore coral:30 ore:20, 5 !chestAndRuins, 6 +hqLevel1 coral:30 ore:20, 6 +laboratoryAndResearch coral:30 ore:20, 6 >algaeFarm, 6 !techChoice, 7 +solarPanelLevel2 coral:30 ore:20, 7 !raidAnnounced, 8 +coralCitadel coral:60 ore:40 algae:40, 8 !events storm, 9 +firstRaid coral:30 ore:20, 9 +descentModule coral:100 ore:70 algae:60, 9 !raidReport lair monsterFamilies descent abyssListens, 10 +pressureCapsule coral:150 ore:100 algae:90, 10 !ancients, 11 +takeLair coral:60 ore:40 algae:40, 11 +kernelLevel1 coral:200 ore:140 algae:120, 11 !awakening, 12 +hqLevel2 coral:30 ore:20, 12 !factionAttack, 13 +algaeFarm coral:30 ore:20, 13 >hqLevel5, 13 !admiral, 15 +takeFaille coral:100 ore:70 algae:60, 15 !caravan postDefence, 16 Ncaravan, 16 !lastChance, 17 +descendLevel2 coral:100 ore:70 algae:60, 17 !forgeTowers", "570 1370 880 100 5"],
		"faction-murenaHorde": ["1 >hqLevel1, 1 !transitionBase, 2 +solarPanel coral:30 ore:20, 2 !noiseGauge, 4 +barracksAndScouts coral:30 ore:20, 5 +hqLevel1 coral:30 ore:20, 5 >algaeFarm, 6 +explore coral:30 ore:20, 6 +solarPanelLevel2 coral:30 ore:20, 6 !events warmCurrent, 7 NwarmCurrent, 7 +coralCitadel coral:60 ore:40 algae:40, 8 +laboratoryAndResearch coral:30 ore:20, 8 +descentModule coral:100 ore:70 algae:60, 8 !techChoice raidAnnounced descent, 9 +pressureCapsule coral:150 ore:100 algae:90, 10 +firstRaid coral:30 ore:20, 10 +kernelLevel1 coral:200 ore:140 algae:120, 10 !raidReport abyssListens awakening, 11 +hqLevel2 coral:30 ore:20, 11 !ancients, 12 +algaeFarm coral:30 ore:20, 12 +takeLair coral:60 ore:40 algae:40, 12 >mines, 12 !coldCurrent, 13 NcoldCurrent, 13 +mines coral:30 ore:20, 13 >hqLevel5, 13 !factionAttack, 14 !admiral, 16 +takeFaille coral:100 ore:70 algae:60, 16 !postDefence, 17 !lastChance, 18 +descendLevel2 coral:100 ore:70 algae:60, 18 !chestAndRuins forgeTowers, 19 !survivors, 20 Ysurvivors", "570 1370 880 100 5"],
		"faction-wreckPillagers": ["1 +solarPanel coral:30 ore:20, 1 >hqLevel1, 1 !transitionBase, 3 !noiseGauge, 4 +hqLevel1 coral:30 ore:20, 4 >algaeFarm, 5 +solarPanelLevel2 coral:30 ore:20, 5 !events warmCurrent, 6 NwarmCurrent, 6 +barracksAndScouts coral:30 ore:20, 6 +coralCitadel coral:60 ore:40 algae:40, 7 +explore coral:30 ore:20, 7 +descentModule coral:100 ore:70 algae:60, 7 !descent, 8 +pressureCapsule coral:150 ore:100 algae:90, 9 +kernelLevel1 coral:200 ore:140 algae:120, 9 !raidAnnounced awakening, 10 +hqLevel2 coral:30 ore:20, 10 +laboratoryAndResearch coral:30 ore:20, 10 !techChoice, 11 +algaeFarm coral:30 ore:20, 11 +firstRaid coral:30 ore:20, 11 >mines, 11 !raidReport chestAndRuins storm abyssListens, 12 !ancients, 13 +mines coral:30 ore:20, 13 +takeLair coral:60 ore:40 algae:40, 13 >hqLevel5, 14 !factionAttack, 15 !admiral, 17 +takeFaille coral:100 ore:70 algae:60, 17 !survivors postDefence, 18 Nsurvivors, 18 !lastChance, 19 +descendLevel2 coral:100 ore:70 algae:60, 19 !lair monsterFamilies forgeTowers", "570 1370 880 100 5"],
		"next": 911,
	},
	"easy-24-two": {
		"human": ["1 +algaeFarm coral:30 ore:20, 1 >hqLevel1, 2 !noiseGauge, 3 +mines coral:30 ore:20, 4 +solarPanel coral:30 ore:20, 4 +explore coral:30 ore:20, 4 !techChoice lair monsterFamilies chestAndRuins, 5 ~wreck/10, 5 !events wreck, 6 +barracksAndScouts coral:30 ore:20, 6 +laboratoryAndResearch coral:30 ore:20, 6 ~wreck/10, 6 !raidAnnounced, 7 +hqLevel1 coral:30 ore:20, 7 >hqLevel2, 7 ~wreck/10, 8 +solarPanelLevel2 coral:30 ore:20, 8 +firstRaid coral:30 ore:20, 8 ~wreck/10, 8 !raidReport abyssListens, 9 +coralCitadel coral:60 ore:40 algae:40, 9 ~wreck/10, 9 !ancients, 10 -wreck/10 expired, 10 +takeLair coral:60 ore:40 algae:40, 10 +descentModule coral:100 ore:70 algae:60, 10 !descent, 11 +pressureCapsule coral:150 ore:100 algae:90, 11 !warmCurrent factionAttack, 12 +kernelLevel1 coral:200 ore:140 algae:120, 12 !admiral awakening, 13 +hqLevel2 coral:30 ore:20, 13 >hqLevel5, 14 +takeFaille coral:100 ore:70 algae:60, 14 !postDefence, 15 !lastChance, 16 +descendLevel2 coral:100 ore:70 algae:60, 16 ~wreck/21, 16 !forgeTowers, 17 ~wreck/21, 18 +takeKernel coral:200 ore:140 algae:120, 18 ~wreck/21, 18 !kernelGarrison, 19 ~wreck/21, 20 ~wreck/21", "690 1570 1020 100 5"],
		"faction-krakenFaithful": ["1 >hqLevel1, 1 !noiseGauge transitionBase, 2 +mines coral:30 ore:20, 3 +solarPanel coral:30 ore:20, 5 +barracksAndScouts coral:30 ore:20, 5 +explore coral:30 ore:20, 5 !chestAndRuins, 6 +hqLevel1 coral:30 ore:20, 6 +laboratoryAndResearch coral:30 ore:20, 6 >algaeFarm, 6 !techChoice, 7 +solarPanelLevel2 coral:30 ore:20, 7 !raidAnnounced events storm, 8 +coralCitadel coral:60 ore:40 algae:40, 9 +firstRaid coral:30 ore:20, 9 +descentModule coral:100 ore:70 algae:60, 9 !raidReport descent abyssListens, 10 +pressureCapsule coral:150 ore:100 algae:90, 10 !ancients, 11 +takeLair coral:60 ore:40 algae:40, 11 +kernelLevel1 coral:200 ore:140 algae:120, 11 !awakening, 12 +hqLevel2 coral:30 ore:20, 12 !warmCurrent factionAttack, 13 YwarmCurrent, 13 +algaeFarm coral:30 ore:20, 13 >hqLevel5, 13 !admiral, 15 +takeFaille coral:100 ore:70 algae:60, 15 !postDefence, 16 !lastChance, 17 +descendLevel2 coral:100 ore:70 algae:60, 17 !lair monsterFamilies predators forgeTowers, 18 Ypredators, 18 -predators/18 failed", "399 959 616 70 5"],
		"faction-murenaHorde": ["1 >hqLevel1, 2 +solarPanel coral:30 ore:20, 2 !noiseGauge, 4 +barracksAndScouts coral:30 ore:20, 5 +hqLevel1 coral:30 ore:20, 5 >algaeFarm, 6 +explore coral:30 ore:20, 6 +solarPanelLevel2 coral:30 ore:20, 6 !lair monsterFamilies, 7 +coralCitadel coral:60 ore:40 algae:40, 7 !events storm, 8 +laboratoryAndResearch coral:30 ore:20, 8 +descentModule coral:100 ore:70 algae:60, 8 !techChoice raidAnnounced descent, 9 +pressureCapsule coral:150 ore:100 algae:90, 10 +firstRaid coral:30 ore:20, 10 +kernelLevel1 coral:200 ore:140 algae:120, 10 !raidReport chestAndRuins abyssListens awakening, 11 +hqLevel2 coral:30 ore:20, 11 !ancients, 12 +algaeFarm coral:30 ore:20, 12 +takeLair coral:60 ore:40 algae:40, 12 >mines, 12 !coldCurrent, 13 NcoldCurrent, 13 +mines coral:30 ore:20, 13 >hqLevel5, 13 !factionAttack, 14 !transitionBase admiral, 16 +takeFaille coral:100 ore:70 algae:60, 16 !postDefence, 17 !lastChance, 18 +descendLevel2 coral:100 ore:70 algae:60, 18 !forgeTowers, 20 !warmCurrent", "570 1370 880 100 5"],
		"next": 736,
	},
}
## Name: [seed, difficulty, factions].
const GAMES: Dictionary[String, Array] = {
	"solo-3": [3, Difficulty.Value.NORMAL, 0],
	"hard-11-three": [11, Difficulty.Value.HARD, 3],
	"easy-24-two": [24, Difficulty.Value.EASY, 2],
}


func test_objectives_resolve_as_dart_resolves_them_on_new_games() -> void:
	for name: String in GAMES:
		var seed_: int = GAMES[name][0]
		var difficulty: Difficulty.Value = GAMES[name][1]
		var count: int = GAMES[name][2]
		var game := GameFactory.new_game("Nemo", seed_, difficulty, false, count, null, "human")
		var random := DartRandom.new(seed_)
		var logs := {}
		var seen := {}
		for id: String in game.players:
			logs[id] = PackedStringArray()
			var none: Dictionary[TipId.Value, bool] = {}
			seen[id] = none
		var current := {}
		for t: int in range(1, 21):
			game.turn = t
			var index := 0
			for player: Player in game.players.values():
				var log_: PackedStringArray = logs[player.id]
				_turn(game, player, t, index, random, log_)
				var now := _current(game, player)
				if current.get(player.id) != now:
					log_.append("%d >%s" % [t, now])
				current[player.id] = now
				for active: TemporaryObjective in TemporaryObjectives.active_of(game, player):
					log_.append(ObjectiveDigests.temporary(t, active))
				var tips: Dictionary[TipId.Value, bool] = seen[player.id]
				var fresh := ObjectiveDigests.fresh_tips(game, player, t, tips)
				if not fresh.is_empty():
					log_.append(fresh)
				index += 1
		var expected: Dictionary = DIGESTS[name]
		for player: Player in game.players.values():
			var log_: PackedStringArray = logs[player.id]
			var stocks := PackedStringArray()
			for stock: GameResource in player.resources.values():
				stocks.append(str(stock.amount))
			assert_eq([", ".join(log_), " ".join(stocks)], expected[player.id], "%s %s" % [name, player.id])
		assert_eq(game.players.size() + 1, expected.size(), name)
		assert_eq(random.next_int(1000), expected["next"], name)


func _turn(game: Game, player: Player, t: int, index: int, random: DartRandom, log_: PackedStringArray) -> void:
	ObjectiveDigests.develop(game, player, t, index)
	player.raid_state.add_noise((t * 7 + index * 3) % 11)
	var choice := EventDigests.choose(game, player, t, index)
	if not choice.is_empty():
		log_.append(choice)
	var outcome := EventResolver.resolve(game, player, t, random)
	for end: TemporaryObjectiveEnd in TemporaryObjectives.ended_by(outcome):
		log_.append(ObjectiveDigests.temporary(t, end.objective, end.outcome))
	for done: ObjectiveCompletion in ObjectiveResolver.resolve(game, player):
		log_.append(ObjectiveDigests.completion(t, done))


func _current(game: Game, player: Player) -> String:
	var objective := CurrentObjective.of(game, player)
	return "null" if objective == null else DartEnum.name_of(ObjectiveId.Value, objective.id)
