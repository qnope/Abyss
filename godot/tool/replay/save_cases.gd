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


## `saves-<game>`, one per game of `reference/games/`, the biggest file
## (the longest case) first, as ReferenceRun.every_name orders the games.
static func names() -> Array[String]:
	var games := CommittedGame.all()
	games.sort_custom(func(a: CommittedGame, b: CommittedGame) -> bool:
		return a.text_length > b.text_length or (a.text_length == b.text_length and a.name < b.name))
	var all: Array[String] = []
	for game: CommittedGame in games:
		all.append(PREFIX + game.name)
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
