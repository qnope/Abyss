class_name ScriptTurn
extends RefCounted
## lib/domain/script/script_turn.dart: what a GameScript sees and does during
## one turn.
##
## Every action goes through ActionExecutor, exactly like a tap in the game
## screen, so a scripted game follows the same rules as a real one.
##
## Dart's field `random` is the method `random()`: a faction's turn
## (`FactionTurn`) overrides that getter to hand each action a generator of
## its own.

var game: Game
## The player this turn acts for; the human player unless another one is
## given, so a strategy can play a faction as well.
var player: Player

var _random: DartRandom
var _log: Array[ScriptLogEntry]
var _executor: ActionExecutor


func _init(
	game_: Game,
	random_: DartRandom,
	log_: Array[ScriptLogEntry],
	player_: Player = null,
	executor: ActionExecutor = null,
) -> void:
	game = game_
	_random = random_
	_log = log_
	player = player_ if player_ != null else game_.human_player()
	_executor = executor if executor != null else ActionExecutor.new()


## The game's seeded generator; give it to every action that rolls dice so
## that a seed always replays the same game.
func random() -> DartRandom:
	return _random


## The same turn, played for `other` instead.
func as_player(other: Player) -> ScriptTurn:
	return ScriptTurn.new(game, random(), _log, other, _executor)


## Number of the turn being played.
func number() -> int:
	return game.turn


func is_over() -> bool:
	return game.status != GameStatus.Value.PLAYING


## Whether `action` would succeed now, without performing or logging it.
func allows(action: Action) -> bool:
	return not is_over() and action.validate(game, player).is_success


## Performs `action` and logs the outcome. A successful action may win the
## game, as it does in the game screen.
func perform(action: Action) -> ActionResult:
	if is_over():
		return ActionResult.failure(ActionFailure.Value.GAME_OVER)
	var result := _executor.execute(action, game, player)
	_log.append(ScriptLogEntry.new(number(), action.description(), result.is_success, result.reason))
	if result.is_success:
		var status: Variant = VictoryChecker.check(game)
		if status != null:
			game.status = status
	return result


## Performs `action` only when it would succeed; returns whether it did.
func try_perform(action: Action) -> bool:
	return allows(action) and perform(action).is_success
