class_name CurrentEffect
extends EventEffect
## lib/domain/event/effects/current_effect.dart: the warm and cold currents,
## which change the production of EFFECT_TURNS turns (see EventProduction).
##
## Exploiting a warm current lifts the production but makes noise every
## turn; letting it pass changes nothing. A cold current always lasts:
## heating the farms keeps the algae for energy, enduring it costs algae.

## WARM_CURRENT or COLD_CURRENT.
var type: RandomEventType.Value


func _init(type_: RandomEventType.Value) -> void:
	type = type_


func _warm() -> bool:
	return type == RandomEventType.Value.WARM_CURRENT


func apply(_game: Game, player: Player, accept: bool, turn: int, _random: DartRandom = null) -> void:
	if _warm() and not accept:
		return
	player.event_state.activate(type, turn + EventRules.EFFECT_TURNS - 1)
	player.event_state.heating = not _warm() and accept


func on_turn_end(_game: Game, player: Player, _turn: int) -> void:
	if _warm():
		player.raid_state.add_noise(EventRules.WARM_NOISE_PER_TURN)
