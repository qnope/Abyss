class_name FactionWarRecruit
extends RefCounted
## lib/domain/faction/faction_war_recruit.dart: a faction arms for war with
## its personality's own mix of units, within the share of the stocks the
## personality gives it. A type its barracks does not train yet, or that it
## already recruited this turn, is left out of the mix.
##
## It only arms while it has seen the base of someone else: a faction alone
## has nobody to fight, and its stocks go to the race.


static func play(turn: ScriptTurn, traits: FactionTraits) -> void:
	var share := traits.share_on(turn.number())
	if share <= 0 or not _knows_a_rival(turn):
		return
	var mix: Dictionary[UnitType.Value, int] = {}
	for type: UnitType.Value in traits.war_mix:
		var alone: Array[Dictionary] = [{type: 1}]
		if not RecruitMoves.usable_mixes(turn, alone).is_empty():
			mix[type] = traits.war_mix[type]
	if mix.is_empty():
		return
	var k := RecruitMoves.affordable(turn, mix, share)
	if k > 0:
		RecruitMoves.recruit_mix(turn, mix, k)


static func _knows_a_rival(turn: ScriptTurn) -> bool:
	var seen := GridPosition.keys(turn.player.revealed_cells_on_level(RaidBattle.BASE_LEVEL))
	for p: Player in turn.game.players.values():
		if (
			p.id != turn.player.id
			and not p.has_fallen()
			and seen.has(Vector2i(p.base_x, p.base_y))
		):
			return true
	return false
