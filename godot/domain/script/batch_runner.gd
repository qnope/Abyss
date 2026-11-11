class_name BatchRunner
extends RefCounted
## lib/domain/script/batch_runner.dart: plays the same script on many
## seeds, to measure a strategy rather than a lucky game.
##
## Dart's `run` is asynchronous, for its isolates; here it gives the report
## once every game is played (GameWorkers).

var runner: ScriptRunner
## Games played at the same time in Dart, each in its own isolate; 1 plays
## them one after the other on the calling isolate. Godot plays them one
## after the other whatever this says.
var workers: int


func _init(runner_: ScriptRunner = null, workers_ := 1) -> void:
	if workers_ < 1:
		push_error("BatchRunner: %d workers, at least 1" % workers_)
	runner = runner_ if runner_ != null else ScriptRunner.new()
	workers = workers_


## Plays `games` games with seeds `first_seed`, `first_seed + 1`, ...
##
## `build` (an int seed -> GameScript) makes a fresh script for the seed of
## each game, so a script that keeps state between turns never leaks it into
## the next game. The runs come back in seed order whatever the number of
## workers.
func run(build: Callable, games: int, first_seed := 1) -> BatchReport:
	var play := func(i: int) -> ScriptRunReport:
		var script: GameScript = build.call(first_seed + i)
		return runner.run(script, first_seed + i)
	var runs: Array[ScriptRunReport] = []
	if workers == 1:
		for i: int in games:
			runs.append(play.call(i))
	else:
		runs.assign(GameWorkers.new(workers).map(games, play))
	return BatchReport.new(runs)
