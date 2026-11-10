class_name GuideRaid
extends RefCounted
## lib/domain/objective/guide/guide_raid.dart: what the guide says once the
## first raid is announced: how many Harpoonists to have on the base level
## to push it back, as RaidDefenceAdvisor sizes them.


## The advice against the raid announced to `player`, the halo on `target`:
## the Harpoonists, or the end of the turn when they were already recruited
## this turn. A raid announced holds its wave and its turn.
static func of(game: Game, player: Player, target: GuideTarget) -> GuideAdvice:
	var wave := player.raid_state.incoming
	var arrival: int = player.raid_state.arrival_turn
	var monsters := wave.total_count()
	var needed: Variant = RaidDefenceAdvisor.harpoonists_for(player, wave)
	if needed == null:
		return GuideAdvice.new(GuideRaidAlert.new(arrival, monsters), target)
	var harpoonists: int = needed
	var have: int = RaidBattle.defenders_of(player).get(UnitType.Value.HARPOONIST, 0)
	if have >= harpoonists:
		return GuideAdvice.new(GuideRaidAlert.new(arrival, monsters, harpoonists), GuideTarget.for_end_turn())
	var can_recruit: bool = target.unit == UnitType.Value.HARPOONIST
	var alert := GuideRaidAlert.new(
		arrival, monsters, harpoonists, harpoonists - have, can_recruit, arrival <= game.turn
	)
	return GuideAdvice.new(alert, target)
