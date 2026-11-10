class_name EventEffect
extends RefCounted
## lib/domain/event/effects/event_effect.dart: what one random event does to
## a player. Every hook does nothing until the event overrides it.


## Whether the event may be drawn at the end of `ended_turn`.
func allowed_at(_game: Game, _player: Player, _ended_turn: int) -> bool:
	return true


## Prepares the event the moment it is drawn at the end of `turn`, with the
## dice of that end of turn.
func on_draw(_game: Game, _player: Player, _turn: int, _random: DartRandom) -> void:
	pass


## Why the player may not take the first option now (an
## ActionFailure.Value), or null when they may. The prudent option is always
## open.
func refusal(_game: Game, _player: Player) -> Variant:
	return null


## Plays the event out from `turn`, the first turn whose end it can still
## change: the turn of the choice when the player chooses, the next one when
## it is applied while a turn ends (that turn's production is already made).
## So an effect lasting n turns from `turn` always covers n productions.
## `accept` is the player's choice, false for the prudent option applied when
## the turn ended without one, and true for an event drawn without a choice.
## `random` is null where Dart passes none.
func apply(_game: Game, _player: Player, _accept: bool, _turn: int, _random: DartRandom = null) -> void:
	pass


## Upkeep of the event's lasting effect at the end of `turn`, one of the
## turns it covers.
func on_turn_end(_game: Game, _player: Player, _turn: int) -> void:
	pass


## Runs at the end of every turn `turn`, after the lasting effects end and
## before the next draw, whether the event lasts or not: for what it left on
## the map.
func on_any_turn_end(_game: Game, _player: Player, _turn: int) -> void:
	pass
