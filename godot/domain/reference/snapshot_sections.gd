class_name SnapshotSections
extends RefCounted
## lib/domain/reference/snapshot_sections.dart: the sections a game snapshot
## is split in, so that two games that differ tell where. Each one is a
## group of fields of Game or of Player, by their Dart names (a set, the
## keys of a Dictionary), or one level of the world.

## Sections made of fields of the game itself.
const OF_GAME: Dictionary[String, Dictionary] = {
	"game": {"humanPlayerId": true, "turn": true, "status": true, "savedDifficulty": true, "savedFactions": true},
	"journal": {"replay": true},
	"leviathan": {"leviathanReturn": true},
}

## Sections made of fields of every player, in playing order.
const OF_PLAYERS: Dictionary[String, Dictionary] = {
	"players": {"name": true, "id": true, "baseX": true, "baseY": true, "savedFallen": true},
	"resources": {"resources": true},
	"buildings": {"buildings": true},
	"worksite": {"worksite": true},
	"tech": {"techBranches": true},
	"units": {"unitsPerLevel": true, "recruitedUnitTypes": true},
	"orders": {"pendingExplorations": true, "pendingReinforcements": true},
	"fog": {"revealedCellsPerLevel": true},
	"raids": {"raidState": true},
	"volcano": {"volcanoState": true},
	"events": {"eventState": true},
	"objectives": {"savedObjectiveState": true},
	"intel": {"savedIntel": true},
	"history": {"historyEntries": true},
}

## The levels of the world, each one a section named `of_level`.
const LEVELS: Array[int] = [1, 2, 3]


static func of_level(level: int) -> String:
	return "map%d" % level


## Every section, in the order a snapshot lists them: by name.
static func names() -> Array[String]:
	var found: Array[String] = []
	found.append_array(OF_GAME.keys())
	found.append_array(OF_PLAYERS.keys())
	for level: int in LEVELS:
		found.append(of_level(level))
	CanonicalKeys.sort(found)
	return found
