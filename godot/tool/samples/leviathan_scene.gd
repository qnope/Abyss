class_name LeviathanScene
extends RefCounted
## The twin of test/domain/leviathan/leviathan_scene.dart: a game against two
## factions where the human holds a Faille with its Module de descente at
## level 2, at turn 12 (PostWar), and the guardians' counter-attack
## scheduled by its capture this very turn. The extension
## `LeviathanSceneTurns` of that file is the static functions that take the
## PostWar first.


## `leviathanScene`.
static func of(map_seed := 7) -> PostWar:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE, map_seed, true)
	LeviathanResolver.on_capture(war.game, war.human(), war.post, war.level, war.at)
	return war


static func leviathan(war: PostWar) -> LeviathanReturn:
	return war.game.leviathan_return


## The turn at the end of which the guardians strike.
static func strike_turn(war: PostWar) -> int:
	return war.game.leviathan_return.due_turn()


## Ends turns (the leviathan step only) until `turn` is the current one.
static func play_until(war: PostWar, turn: int, seed_ := 3) -> void:
	while war.game.turn < turn:
		end_turn(war, seed_)


## Runs the leviathan step of the end of the current turn.
static func end_turn(war: PostWar, seed_ := 3) -> LeviathanTurnOutcome:
	var outcome := LeviathanResolver.resolve(war.game, DartRandom.new(seed_))
	war.game.turn += 1
	return outcome
