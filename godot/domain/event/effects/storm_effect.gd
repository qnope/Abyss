class_name StormEffect
extends EventEffect
## lib/domain/event/effects/storm_effect.dart: the storm, which forbids
## exploring for STORM_TURNS turns but covers the noise: the gauge loses
## STORM_NOISE_RELIEF points at once. Explorations ordered before it still
## resolve.


func apply(_game: Game, player: Player, _accept: bool, turn: int, _random: DartRandom = null) -> void:
	player.event_state.activate(RandomEventType.Value.STORM, turn + EventRules.STORM_TURNS - 1)
	player.raid_state.quiet(EventRules.STORM_NOISE_RELIEF)
