class_name SurvivorsEffect
extends EventEffect
## lib/domain/event/effects/survivors_effect.dart: survivors who may join
## the base as free harpoonists: no cost, no noise, and they leave the
## turn's recruitment open. They eat algae like any unit.


## Survivors met at the end of `ended_turn`: SURVIVORS_MIN, one more every
## SURVIVORS_TURNS_PER_EXTRA turns, up to SURVIVORS_MAX.
static func count_at(ended_turn: int) -> int:
	return mini(
		EventRules.SURVIVORS_MAX,
		EventRules.SURVIVORS_MIN + DartMath.trunc_div(ended_turn, EventRules.SURVIVORS_TURNS_PER_EXTRA),
	)


func on_draw(_game: Game, player: Player, turn: int, _random: DartRandom) -> void:
	player.event_state.survivors = count_at(turn)


## Welcomed, the survivors met at the draw join the units of level 1.
func apply(_game: Game, player: Player, accept: bool, _turn: int, _random: DartRandom = null) -> void:
	var met: Variant = player.event_state.survivors
	var count: int = 0 if met == null else met
	if not accept or count <= 0:
		return
	KernelGarrison.stock_at(player, 1)[UnitType.Value.HARPOONIST].count += count
