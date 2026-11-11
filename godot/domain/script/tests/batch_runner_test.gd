extends TestCase
## test/domain/script/batch_runner_test.dart. Godot plays the games of any
## number of workers one after the other (GameWorkers): the reports are
## Dart's all the same.

var _runner := ScriptRunner.new(30)


## Stops on its first turn, named after the seed it was built for.
class _SeedScript:
	extends GameScript
	var seed_of: int

	func _init(seed_: int) -> void:
		seed_of = seed_

	func name() -> String:
		return "seed %d" % seed_of

	func last_turn() -> Variant:
		return 1

	func play_turn(_turn: ScriptTurn) -> void:
		pass


func test_builds_one_script_per_seed_in_seed_order() -> void:
	var report := BatchRunner.new(_runner).run(_SeedScript.new, 4, 5)

	assert_eq(_names(report), ["seed 5", "seed 6", "seed 7", "seed 8"])
	assert_eq(report.runs.map(func(r: ScriptRunReport) -> int: return r.run_seed), [5, 6, 7, 8])


func test_with_several_workers_every_seed_is_built_once() -> void:
	var report := BatchRunner.new(_runner, 3).run(_SeedScript.new, 5, 5)

	var names := _names(report)
	names.sort()
	assert_eq(names, ["seed 5", "seed 6", "seed 7", "seed 8", "seed 9"])


func test_several_workers_give_the_very_report_of_a_single_one() -> void:
	var balanced := func(_seed: int) -> GameScript: return BalancedStrategy.new()
	var sequential := BatchRunner.new(_runner).run(balanced, 6)
	var parallel := BatchRunner.new(_runner, 3).run(balanced, 6)

	assert_eq(parallel.runs.size(), sequential.runs.size())
	for i: int in sequential.runs.size():
		assert_eq(parallel.runs[i].run_seed, sequential.runs[i].run_seed)
		assert_eq(parallel.runs[i].to_json(), sequential.runs[i].to_json())
		assert_eq(parallel.runs[i].log.map(str), sequential.runs[i].log.map(str))
	assert_eq(parallel.to_json(), sequential.to_json())


func test_more_workers_than_games_still_plays_every_game_once() -> void:
	var report := BatchRunner.new(_runner, 8).run(_SeedScript.new, 2)

	assert_eq(report.runs.map(func(r: ScriptRunReport) -> int: return r.run_seed), [1, 2])


func test_plays_with_a_default_runner_when_given_none() -> void:
	var report := BatchRunner.new().run(_SeedScript.new, 2)

	assert_eq(_names(report), ["seed 1", "seed 2"])


func test_no_game_at_all_gives_an_empty_report() -> void:
	var report := BatchRunner.new(_runner, 3).run(_SeedScript.new, 0)

	assert_eq(report.runs.size(), 0)
	assert_eq(report.games(), 0)


## Not in the Dart file: no worker at all is refused, where Dart asserts.
func test_refuses_fewer_than_one_worker() -> void:
	expect_error("BatchRunner: 0 workers, at least 1")
	BatchRunner.new(_runner, 0)
	expect_error("GameWorkers: 0 workers, at least 1")
	GameWorkers.new(0)


static func _names(report: BatchReport) -> Array:
	return report.runs.map(func(r: ScriptRunReport) -> String: return r.script_name)
