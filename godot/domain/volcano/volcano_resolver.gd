class_name VolcanoResolver
extends RefCounted
## lib/domain/volcano/volcano_resolver.dart: end-of-turn step of the
## volcano: fights the wave due this turn, then announces the next one while
## the kernel stands between levels 1 and 9. The first wave a holder (human
## or faction) ever faces comes at half strength; it is told apart by the
## outcomes VolcanoState counts. A wave due the turn the kernel lost a siege
## (the factions play before this step) is held back one turn, so a won
## siege costs one level only; it is called off when the siege took the
## kernel.

## From this kernel level on, the game is won and the waves stop.
const WIN_LEVEL := 10


## `random` null is Dart's own die for the fight. A wave fought goes to
## the player's history.
static func resolve(
	player: Player,
	ended_turn: int,
	random: DartRandom = null,
	difficulty := Difficulty.Value.NORMAL,
	is_faction := false,
	factions := 0,
) -> VolcanoTurnOutcome:
	var state := player.volcano_state
	var report: VolcanoReport = null
	var due: bool = state.is_incoming() and state.arrival_turn <= ended_turn
	if due and player.raid_state.kernel_siege_lost_turn == ended_turn:
		# A siege that took the kernel leaves the wave nothing to retake.
		if KernelGarrison.kernel_level_of(player) < 1:
			state.clear_incoming()
			return VolcanoTurnOutcome.new()
		state.announce(state.incoming, ended_turn + 1)
		return VolcanoTurnOutcome.new(null, state.incoming)
	if due:
		report = VolcanoBattle.fight(player, state.incoming, ended_turn, random)
		state.record_outcome(report.victory)
		player.add_history_entry(_entry_of(report))
		state.clear_incoming()
	var level := KernelGarrison.kernel_level_of(player)
	if state.is_incoming() or level < 1 or level >= WIN_LEVEL:
		return VolcanoTurnOutcome.new(report)
	var wave := VolcanoWaveFactory.from_kernel_level(
		level,
		Difficulty.monster_percent_for(difficulty, is_faction, factions),
		state.waves_fought() == 0,
	)
	state.announce(wave, ended_turn + 1)
	return VolcanoTurnOutcome.new(report, wave)


static func _entry_of(r: VolcanoReport) -> VolcanoEntry:
	return VolcanoEntry.new(
		r.turn, r.victory, r.wave, r.fight, r.kernel_level, r.defenders, r.survivors_intact,
		r.wounded, r.dead,
	)
