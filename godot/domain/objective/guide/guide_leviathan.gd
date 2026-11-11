class_name GuideLeviathan
extends RefCounted
## lib/domain/objective/guide/guide_leviathan.dart: the guide's most urgent
## word: the guardians strike the Faille at the end of this turn
## (LeviathanResolver.announced_now). The halo points at the Faille, whose
## sheet sends units down.


## The alert for `player` in `game`, null when no counter-attack strikes
## this turn.
static func of(game: Game, player: Player) -> GuideAdvice:
	var attack := LeviathanResolver.announced_now(game)
	if attack == null or player.id != game.human_player_id:
		return null
	var level := attack.defending_level()
	var have := 0
	for unit: Unit in player.units_on_level(level).values():
		have += unit.count
	var needed: Variant = LeviathanDefenceAdvisor.units_for(game, player, level)
	var missing := 0 if needed == null else _missing(needed, have)
	return GuideAdvice.new(GuideLeviathanReturn.new(level, missing), GuideTarget.for_cell(attack.level, attack.at))


## The units `needed` (an int) less those `have`, 0 when they suffice. The
## advisor's null, which no game reaches, never comes here.
static func _missing(needed: Variant, have: int) -> int:
	var wanted: int = needed
	return 0 if wanted <= have else wanted - have
