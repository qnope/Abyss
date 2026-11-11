class_name ReferenceMilestones
extends RefCounted
## lib/domain/reference/reference_milestones.dart: how far a reference game
## went, to tell what the set of games covers: the turn the human took each
## step of the road to the volcano, the raids and the kraken waves fought,
## the guardians' return, the factions that fell and who tamed the volcano.


static func of(game: Game, milestones: ScriptMilestones) -> Dictionary:
	var human := game.human_player()
	var winner := VictoryChecker.winner_of(game)
	var fallen := 0
	for p: Player in game.players.values():
		if p.has_fallen():
			fallen += 1
	return {
		"failleCaptured": milestones.faille_captured,
		"chemineeCaptured": milestones.cheminee_captured,
		"kernelCaptured": milestones.kernel_captured,
		"leviathanStruck": milestones.leviathan_struck,
		"leviathanHeld": milestones.leviathan_held,
		"raidsRepelled": human.raid_state.raids_repelled,
		"raidsLost": human.raid_state.raids_lost,
		"wavesRepelled": human.volcano_state.waves_repelled,
		"wavesLost": human.volcano_state.levels_lost,
		"fallenFactions": fallen,
		"winner": null if winner == null else PlayerIds.new(human.id).of(winner.id),
	}
