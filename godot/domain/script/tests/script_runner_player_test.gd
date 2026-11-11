extends TestCase
## test/domain/script/script_runner_player_test.dart.

## Captured from the Dart runner before it could play any player;
## recaptured when the tutorial gained its Solar Panel level 2 step.
const CONQUEST_SEED_1_TURN_30 := (
	'{"script":"conquest","seed":1,"status":"playing","turnsPlayed":30,'
	+ '"raidsRepelled":4,"raidsLost":2,"monstersDefeated":0,"totalNoise":'
	+ '320,"failedActions":0,"buildings":{"headquarters":7,"algaeFarm":4,'
	+ '"coralMine":4,"oreExtractor":4,"solarPanel":4,"laboratory":3,"barr'
	+ 'acks":3,"coralCitadel":0,"descentModule":0,"pressureCapsule":0,"vo'
	+ 'lcanicKernel":0},"baseUnits":{"scout":0,"harpoonist":3,"guardian":'
	+ '0,"domeBreaker":0,"abyssAdmiral":1,"saboteur":0},"resources":{"alg'
	+ 'ae":5000,"coral":709,"ore":1342,"energy":355,"pearl":10},"failleCa'
	+ 'ptured":null,"chemineeCaptured":null,"kernelCaptured":null,"leviat'
	+ 'hanStruck":null,"leviathanHeld":null,"raids":[{"turn":13,"monsters'
	+ '":26,"level":1,"victory":false},{"turn":20,"monsters":20,"level":1'
	+ ',"victory":true},{"turn":22,"monsters":38,"level":2,"victory":true'
	+ '},{"turn":25,"monsters":14,"level":2,"victory":false},{"turn":27,"'
	+ 'monsters":15,"level":2,"victory":true},{"turn":29,"monsters":34,"l'
	+ 'evel":3,"victory":true}],"waves":[]}'
)


func test_the_human_conquest_of_seed_1_still_reports_the_same_30_turns() -> void:
	var report := ScriptRunner.new(30).run(ScriptLibrary.by_name("conquest"), 1)

	assert_eq(DartJson.encode(report.to_json()), CONQUEST_SEED_1_TURN_30)


func test_a_runner_plays_a_strategy_for_the_second_player_of_a_game() -> void:
	var game := GameSamples.two_players()
	var rival := _rival(game)
	var human_levels := _levels(game.human_player())

	var report := ScriptRunner.new(5).run_on(game, EconomyStrategy.new(), DartRandom.new(1, false), 1, rival.id)

	assert_eq(report.status, GameStatus.Value.PLAYING)
	assert_eq(report.buildings, _levels(rival))
	assert_eq(_levels(game.human_player()), human_levels)


func test_a_rival_report_counts_the_resources_of_the_rival() -> void:
	var game := GameSamples.two_players()
	game.human_player().resources[ResourceType.Value.ALGAE].amount += 100000

	var report := ScriptRunner.new(3).run_on(game, EconomyStrategy.new(), DartRandom.new(1, false), 1, _rival(game).id)

	assert_true(report.statistics.total_resources_collected < 100000)


static func _rival(game: Game) -> Player:
	for id: String in game.players:
		if id != game.human_player_id:
			return game.players[id]
	return null


static func _levels(player: Player) -> Dictionary[BuildingType.Value, int]:
	var levels: Dictionary[BuildingType.Value, int] = {}
	for type: BuildingType.Value in player.buildings:
		levels[type] = player.buildings[type].level
	return levels
