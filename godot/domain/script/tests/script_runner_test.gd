extends TestCase
## test/domain/script/script_runner_test.dart and
## script_runner_human_id_test.dart.


class _Watching:
	extends ActionExecutor
	var game: Game

	func execute(action: Action, game_: Game, player: Player) -> ActionResult:
		game = game_
		return super.execute(action, game_, player)


## Ends the game as its first turn is played.
class _Ending:
	extends GameScript
	var status: GameStatus.Value
	var seeds: Dictionary[int, int]

	func _init(status_: GameStatus.Value, seeds_: Dictionary[int, int] = {}) -> void:
		status = status_
		seeds = seeds_

	func name() -> String:
		return "ending"

	func play_turn(turn: ScriptTurn) -> void:
		turn.game.status = status

	func end_turn_random(turn: int) -> DartRandom:
		return DartRandom.new(seeds[turn]) if seeds.has(turn) else null


func test_stops_at_the_turn_limit_when_nothing_ends_the_game() -> void:
	var report := ScriptRunner.new(5).run(IdleScript.new(), 1)

	assert_eq(report.status, GameStatus.Value.PLAYING)
	assert_eq(report.turns_played, 5)
	assert_eq(report.log.size(), 0)


func test_replays_the_very_same_game_from_the_same_seed() -> void:
	var runner := ScriptRunner.new(30)
	var first := runner.run(BalancedStrategy.new(), 7)
	var second := runner.run(BalancedStrategy.new(), 7)

	assert_eq(second.to_json(), first.to_json())
	assert_eq(second.log.map(str), first.log.map(str))


func test_plays_every_turn_through_the_action_system() -> void:
	var report := ScriptRunner.new(3).run(BalancedStrategy.new(), 1)

	assert_true(report.log.size() > 0)
	assert_true(report.log.all(func(e: ScriptLogEntry) -> bool: return e.success))
	assert_true(report.log.any(func(e: ScriptLogEntry) -> bool: return e.turn == 1))
	assert_true(report.total_noise > 0)


func test_the_human_of_a_scripted_game_gets_a_drawn_id_by_default() -> void:
	var a := _Watching.new()
	var b := _Watching.new()
	ScriptRunner.new(1, Difficulty.Value.NORMAL, null, a).run(IdleScript.new(), 1)
	ScriptRunner.new(1, Difficulty.Value.NORMAL, null, b).run(IdleScript.new(), 1)

	assert_ne(a.game.human_player_id, b.game.human_player_id)


func test_a_runner_can_pin_the_id_of_the_human() -> void:
	var watching := _Watching.new()
	ScriptRunner.new(1, Difficulty.Value.NORMAL, "pinned", watching).run(IdleScript.new(), 1)

	assert_eq(watching.game.human_player_id, "pinned")


## Not in the Dart files: a game won in a turn stops there; one lost in a
## turn stops there too, unless the script holds the dice of its end (a
## faction tamed the volcano while the turn ended).
func test_a_game_over_in_a_turn_ends_it_only_with_its_recorded_dice() -> void:
	var won := GameCapture.new()
	ScriptRunner.new(5, Difficulty.Value.NORMAL, null, won).run(_Ending.new(GameStatus.Value.VICTORY), 1)
	var lost := GameCapture.new()
	ScriptRunner.new(5, Difficulty.Value.NORMAL, null, lost).run(_Ending.new(GameStatus.Value.DEFEAT), 1)
	var ended := GameCapture.new()
	ScriptRunner.new(5, Difficulty.Value.NORMAL, null, ended).run(_Ending.new(GameStatus.Value.DEFEAT, {1: 3}), 1)

	expect_error("No action was executed")
	assert_null(won.game(), "the turn did not end")
	expect_error("No action was executed")
	assert_null(lost.game(), "the turn did not end")
	assert_eq(ended.game().turn, 2)


## Not in the Dart files: a game played for another player than the human
## reports that player, and the human still ends the turns.
func test_plays_a_game_for_another_player() -> void:
	var game := GameFactory.new_game("p", 3, Difficulty.Value.NORMAL, false, 0, _pearl_order())
	var report := ScriptRunner.new(2).run_on(game, BalancedStrategy.new(), DartRandom.new(1, false), 1, "faction-pearlOrder")

	assert_eq(game.turn, 3)
	assert_true(report.log.size() > 0)
	assert_eq(report.buildings, ScriptRunReport.of(game, "", 0, [], null, "faction-pearlOrder").buildings)
	assert_eq(report.milestones.raids.size(), 0)


func _pearl_order() -> Array[FactionPersonality.Value]:
	return [FactionPersonality.Value.PEARL_ORDER]
