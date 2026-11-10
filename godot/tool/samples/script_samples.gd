class_name ScriptSamples
extends RefCounted
## What the tests of the scripts write inline: a turn of `game`, as
## `ScriptTurn(game: game, random: Random(1), log: [])` builds it.


## A turn of `game` for `player` (the human when null), its dice a plain
## `Random(seed_)` (no SeededRandom, as in the Dart tests), its log `log_`.
static func turn(
	game: Game, player: Player = null, seed_ := 1, log_: Array[ScriptLogEntry] = []
) -> ScriptTurn:
	return ScriptTurn.new(game, DartRandom.new(seed_, false), log_, player)
