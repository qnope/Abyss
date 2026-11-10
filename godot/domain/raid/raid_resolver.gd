class_name RaidResolver
extends RefCounted
## lib/domain/raid/raid_resolver.dart: end-of-turn step of the raid system:
## fights the raid due this turn, adds the base noise and announces the
## next raid once the gauge is full.


## `random` null is Dart's own die for the fight and the families. A raid
## fought goes to the player's history.
static func resolve(
	player: Player,
	ended_turn: int,
	random: DartRandom = null,
	difficulty := Difficulty.Value.NORMAL,
	is_faction := false,
	factions := 0,
) -> RaidTurnOutcome:
	var state := player.raid_state
	var report: RaidReport = null
	if state.is_incoming() and state.arrival_turn <= ended_turn:
		report = RaidBattle.fight(player, state.incoming, ended_turn, random)
		state.record_outcome(report.victory)
		player.add_history_entry(report.to_entry())
		state.clear_incoming()
	state.add_noise(NoiseRules.PER_TURN)
	if state.is_incoming() or state.noise < NoiseRules.THRESHOLD:
		return RaidTurnOutcome.new(report)
	var wave := RaidWaveFactory.from_total_noise(
		state.total_noise,
		random,
		Difficulty.monster_percent_for(difficulty, is_faction, factions),
		DefenceStrength.of(player),
	)
	var arrival := maxi(
		ended_turn + TechEffects.of(player).raid_warning_turns(), NoiseRules.FIRST_RAID_TURN
	)
	# A turn an attack of a faction is announced for is already taken.
	while state.is_attacked_on(arrival):
		arrival += 1
	state.announce(wave, arrival)
	return RaidTurnOutcome.new(report, wave, arrival)
