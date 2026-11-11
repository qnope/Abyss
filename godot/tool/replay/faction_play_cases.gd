class_name FactionPlayCases
extends RefCounted
## Whole games against the factions, too long for the unit tests:
## '$count factions play 60 turns and every one of them grows' of
## test/domain/faction/faction_play_test.dart, and
## test/domain/faction/faction_research_play_test.dart.


## `count` factions play 60 turns and every one of them grows.
static func grow(count: int) -> PackedStringArray:
	var checks := CaseChecks.new()
	var fresh := FactionGames.play(count, 1)
	var before: Dictionary[String, int] = {}
	for faction: Faction in fresh.factions():
		before[faction.id()] = FactionGames.growth_of(fresh.players[faction.id()])

	var game := FactionGames.play(count, 60)

	checks.expect(game.status == GameStatus.Value.PLAYING, "the game is over: %s" % game.status)
	checks.expect(game.turn == 60, "turn %d, not 60" % game.turn)
	for faction: Faction in game.factions():
		var player: Player = game.players[faction.id()]
		var growth := FactionGames.growth_of(player)
		checks.expect(growth > before[faction.id()] + 5, "%s grew from %d to %d only" % [faction.name(), before[faction.id()], growth])
		checks.expect(not player.history_entries.is_empty(), "%s has no history" % faction.name())
	return checks.failures


## The standing factions open the Explorer branch by turn 40.
static func research() -> PackedStringArray:
	var checks := CaseChecks.new()
	var game := FactionGames.play(3, 40)
	var standing: Array[Faction] = []
	for faction: Faction in game.factions():
		if not game.players[faction.id()].has_fallen():
			standing.append(faction)

	checks.expect(not standing.is_empty(), "every faction fell")
	for faction: Faction in standing:
		var explorer: TechBranchState = game.players[faction.id()].tech_branches[TechBranch.Value.EXPLORER]
		checks.expect(explorer.research_level > 0, "%s did not research the Explorer branch" % faction.name())
	return checks.failures
