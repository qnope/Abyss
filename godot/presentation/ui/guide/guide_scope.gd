class_name GuideScope
extends RefCounted
## What the guide of the tutorial points at, handed to every control that may
## carry its halo: the tabs, the cards, the research medallions and nodes, the
## level chips, « Tour suivant » (lib/.../guide_scope.dart, the inherited
## widget). It reads [GuideAdvisor] from the game it is given, and again on
## [method refresh], which [GameActions] calls after every change of the game;
## [signal changed] tells whoever follows it.
##
##     scope.points(func(target: GuideTarget) -> bool: return target.end_turn)

## The advice was read again: the target and the words may have changed.
signal changed

## What the guide says and points at, null when it is silent (the tutorial is
## off or its chapters are over).
var advice: GuideAdvice
## The turn the advice was read at: an exploration to do comes back at each new
## one.
var turn := 0
var _game: Game


## The scope of [param game]; without one the guide is silent.
func _init(game: Game = null) -> void:
	_game = game
	_read()


## Reads the advice again and tells [signal changed]. It takes the result of
## the action that changed the game, which it ignores, so that it can be
## connected to [signal GameActions.acted].
func refresh(_result: Variant = null) -> void:
	_read()
	changed.emit()


## What the halo surrounds, null when the guide is silent.
func target() -> GuideTarget:
	return null if advice == null else advice.target


## Whether the halo surrounds what [param picks] (a Callable taking the
## [GuideTarget] and returning a bool) recognizes in the target.
func points(picks: Callable) -> bool:
	var at := target()
	if at == null:
		return false
	var found: bool = picks.call(at)
	return found


func _read() -> void:
	if _game == null:
		return
	turn = _game.turn
	advice = GuideAdvisor.of(_game, _game.human_player())
