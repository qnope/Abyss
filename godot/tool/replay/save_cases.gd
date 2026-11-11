class_name SaveCases
extends RefCounted
## The saves of the reference games, a case per game (SaveRoundTrip): the
## game saved and loaded as its turns start, and played on from the saves
## of the turns a third and two thirds of the way. A save weighs with the
## histories of the factions (megabytes against ten): a game against `n`
## factions is checked every `n + 1` turns, and played on from two thirds
## only from MANY factions up.

const PREFIX := "saves-"
const MANY := 3


## `saves-<game>`, one per game of `reference/games/`.
static func names() -> Array[String]:
	var all: Array[String] = []
	for game: String in CommittedGame.names():
		all.append(PREFIX + game)
	return all


static func run(name: String) -> PackedStringArray:
	var committed := CommittedGame.named(name.trim_prefix(PREFIX))
	var factions: Array = committed.journal().get("factions", [])
	var turns := committed.turns()
	var third := DartMath.trunc_div(turns.size(), 3)
	var resumed: Array[int] = [turns[2 * third]]
	if factions.size() < MANY:
		resumed.push_front(turns[third])
	return SaveRoundTrip.new(committed, factions.size() + 1, resumed).problems()
