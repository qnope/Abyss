class_name GameSnapshot
extends RefCounted
## lib/domain/reference/game_snapshot.dart: the whole state of a game as
## canonical texts, one per section of SnapshotSections, the same for two
## games in the same state whatever the machine, the day and the id drawn
## for the human, and the same as Dart's for the same game.
##
## It only reads the game. The format is specified in reference/README.md.


## The value of each section, by name, in the order of
## SnapshotSections.names(). A level outside 1 to 3 but 0 (Dart's
## `orElse`), where Dart throws, logs an error and gives an empty
## Dictionary.
static func sections(game: Game) -> Dictionary:
	var ids := PlayerIds.new(game.human_player_id)
	var unknown := 0
	for level: int in game.levels:
		if not SnapshotSections.LEVELS.has(level):
			unknown = level
			break
	if unknown != 0:
		push_error("GameSnapshot: no section for the level %d of the world" % unknown)
		return {}
	var found := {}
	var games := GameSnapshots.game()
	for section: String in SnapshotSections.OF_GAME:
		found[section] = games.only(game, ids, SnapshotSections.OF_GAME[section])
	var players := PlayerSnapshots.player()
	for section: String in SnapshotSections.OF_PLAYERS:
		var rows: Array = []
		for p: Player in game.players.values():
			rows.append([ids.of(p.id), players.only(p, ids, SnapshotSections.OF_PLAYERS[section])])
		found[section] = rows
	var maps := MapSnapshots.game_map()
	for level: int in SnapshotSections.LEVELS:
		var map: GameMap = game.levels.get(level)
		found[SnapshotSections.of_level(level)] = maps.or_null(map, ids)
	var ordered := {}
	for name: String in SnapshotSections.names():
		ordered[name] = found[name]
	return ordered


## The canonical text of each section, by name.
static func texts(game: Game) -> Dictionary[String, String]:
	var written: Dictionary[String, String] = {}
	var values := sections(game)
	for name: String in values:
		written[name] = CanonicalWriter.write(values[name])
	return written


## The digest of each section, in the order of SnapshotSections.names();
## `digest` takes a text and gives its digest (Sha256Hex.of).
static func digests(game: Game, digest: Callable) -> PackedStringArray:
	var found := PackedStringArray()
	for text: String in texts(game).values():
		var hex: String = digest.call(text)
		found.append(hex)
	return found
