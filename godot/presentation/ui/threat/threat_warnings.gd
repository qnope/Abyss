class_name ThreatWarnings
extends RefCounted
## The warnings of the end-of-turn question about the threats that strike this
## turn, in Flutter's order (lib/presentation/screens/game/
## game_screen_turn_helpers.dart: dueWarnings): the raid, the school of
## predators, the guardians on a Faille too weakly held, the kraken wave on an
## unguarded kernel. [TurnWarnings] joins them to its own.


## The threat warnings that apply to [param player] in [param game], in order.
static func of(game: Game, player: Player) -> Array[Control]:
	var found: Array[Control] = []
	for warning: Control in [raid(game, player), predators(game, player), leviathan(game, player), volcano(game, player)]:
		if warning != null:
			found.append(warning)
	return found


## The raid that hits the base at the end of this turn, null when none does.
static func raid(game: Game, player: Player) -> RaidDueWarning:
	var state := player.raid_state
	if not state.is_incoming() or state.arrival_turn > game.turn:
		return null
	return RaidDueWarning.new(state.incoming, ThreatDefenders.on_base(player), false, DefeatChecker.is_last_chance(game))


## The school of predators faced this turn, which strikes at its end. Losing it
## never ends the game.
static func predators(game: Game, player: Player) -> RaidDueWarning:
	var state := player.event_state
	if state.predator_wave == null or state.predators_turn == null or state.predators_turn > game.turn:
		return null
	return RaidDueWarning.new(state.predator_wave, ThreatDefenders.on_base(player), true)


## The guardians that strike the Faille this turn, when the level that defends
## it is empty or would not hold; null otherwise.
static func leviathan(game: Game, player: Player) -> LeviathanDueWarning:
	var attack := LeviathanResolver.announced_now(game)
	if attack == null:
		return null
	var level := attack.defending_level()
	var defenders := ThreatDefenders.on_level(player, level)
	if defenders > 0:
		var needed: Variant = LeviathanDefenceAdvisor.units_for(game, player, level)
		if needed != null and defenders >= needed:
			return null
	return LeviathanDueWarning.new(defenders, level)


## The kraken wave that hits the kernel this turn when no unit guards it.
static func volcano(game: Game, player: Player) -> VolcanoDueWarning:
	var state := player.volcano_state
	if not state.is_incoming() or state.arrival_turn > game.turn or KernelGarrison.size_of(player) > 0:
		return null
	return VolcanoDueWarning.new(state.incoming)
