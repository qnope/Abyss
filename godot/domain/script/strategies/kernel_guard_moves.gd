class_name KernelGuardMoves
extends RefCounted
## lib/domain/script/strategies/kernel_guard_moves.dart: guarding the
## captured kernel against the kraken waves. The Dart extension on
## ScriptTurn: each function takes the turn first.

## Units that hold the kernel: Briseurs against the kraken bosses, Gardiens
## to soak their tentacles (mixes of RecruitMoves).
const GUARD_MIXES: Array[Dictionary] = [
	{UnitType.Value.DOME_BREAKER: 2, UnitType.Value.GUARDIAN: 1},
	{UnitType.Value.DOME_BREAKER: 1},
	{UnitType.Value.HARPOONIST: 1},
]


## Shuts every fighter of the volcano level in the garrison, then recruits
## and brings down what it needs to beat the wave of the kernel's current
## level, with `share` of the stocks at most.
static func guard_kernel(turn: ScriptTurn, planner: ArmyPlanner, share := 1.0) -> void:
	var game := turn.game
	var player := turn.player
	if not game.is_volcanic_kernel_captured_by(player.id):
		return
	var level := KernelGarrison.kernel_level_of(player)
	if level < 1:
		return
	_garrison_volcano_fighters(turn)
	var wave := VolcanoWaveFactory.from_kernel_level(
		level,
		Difficulty.monster_percent_for(game.difficulty(), player.id != game.human_player_id, game.factions().size()),
	)
	var before := _home_counts(turn)
	RecruitMoves.top_up(
		turn,
		KernelGarrison.of(player),
		func() -> Array[Combatant]: return CombatantBuilder.monster_combatants_from(wave),
		GUARD_MIXES,
		planner,
		ExpeditionMoves.defence_boost(turn),
		func() -> Array[Combatant]: return [MagmaRampart.combatant_for(level)],
		false,
		share,
	)
	var recruits: Dictionary[UnitType.Value, int] = {}
	var after := _home_counts(turn)
	for t: UnitType.Value in after:
		if after[t] > before.get(t, 0):
			recruits[t] = after[t] - before[t]
	if recruits.is_empty() or not ExpeditionMoves.descend(turn, 1, recruits):
		return
	ExpeditionMoves.descend(turn, 2, recruits)
	_garrison_volcano_fighters(turn)


static func _garrison_volcano_fighters(turn: ScriptTurn) -> void:
	var fighters := ExpeditionMoves.fighters_on(turn, KernelGarrison.VOLCANO_LEVEL)
	fighters.erase(UnitType.Value.ABYSS_ADMIRAL)
	if fighters.is_empty():
		return
	turn.try_perform(GarrisonKernelAction.new(fighters))


static func _home_counts(turn: ScriptTurn) -> Dictionary[UnitType.Value, int]:
	var counts: Dictionary[UnitType.Value, int] = {}
	var units := turn.player.units_on_level(1)
	for t: UnitType.Value in units:
		counts[t] = units[t].count
	return counts
