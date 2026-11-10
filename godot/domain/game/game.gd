class_name Game
extends RefCounted
## lib/domain/game/game.dart: a game, its players, its levels, where it
## stands. Without `createdAt` and `lastPlayedAt`, wall-clock dates no rule
## reads (reference/README.md, "Fields left out").

## The players by id, the human first, then the factions in the order they
## play.
var players: Dictionary[String, Player]
var human_player_id: String
var turn: int
var levels: Dictionary[int, GameMap]
var status: GameStatus.Value
## Every move played so far, to export the game as a replay.
var replay: ReplayJournal
## Picked when the game started. Null in the old saves, which play in
## normal: NORMAL here.
var saved_difficulty: Difficulty.Value
## Personalities of the factions, in the order they play. Null in the old
## saves and in a single-player game: empty here.
var saved_factions: Array[FactionPersonality.Value] = []
## The guardians' return to the human's first Faille.
var leviathan_return: LeviathanReturn


func _init(
	human_player_id_: String,
	players_: Dictionary[String, Player],
	turn_ := 1,
	levels_: Dictionary[int, GameMap] = {},
	status_ := GameStatus.Value.PLAYING,
	replay_: ReplayJournal = null,
	difficulty_ := Difficulty.Value.NORMAL,
) -> void:
	human_player_id = human_player_id_
	players = players_
	turn = turn_
	levels = levels_
	status = status_
	replay = replay_
	saved_difficulty = difficulty_
	leviathan_return = LeviathanReturn.new()


## `Game.singlePlayer`: a game of `human` alone.
static func single_player(human: Player, difficulty_ := Difficulty.Value.NORMAL) -> Game:
	return Game.new(human.id, {human.id: human}, 1, {}, GameStatus.Value.PLAYING, null, difficulty_)


## The factions of the game, in the order they play; each one is the
## player of the same Faction.id().
func factions() -> Array[Faction]:
	var found: Array[Faction] = []
	for personality: FactionPersonality.Value in saved_factions:
		found.append(Faction.new(personality))
	return found


func difficulty() -> Difficulty.Value:
	return saved_difficulty


## The human player. A game without it, where Dart throws, logs an error
## and gives null.
func human_player() -> Player:
	if not players.has(human_player_id):
		push_error("Game.human_player: no player %s" % human_player_id)
		return null
	return players[human_player_id]


func map_for_level(level: int) -> GameMap:
	return levels.get(level)


## Level 1. A game without it, where Dart throws, logs an error and gives
## null.
func current_map() -> GameMap:
	if not levels.has(1):
		push_error("Game.current_map: no level 1")
		return null
	return levels[1]


## The types of the posts `player_id` holds on every level, a set in the
## order met, level after level.
func captured_base_types_of(player_id: String) -> Dictionary[TransitionBaseType.Value, bool]:
	var types: Dictionary[TransitionBaseType.Value, bool] = {}
	for map: GameMap in levels.values():
		for cell: MapCell in map.cells:
			if cell.transition_base != null and cell.transition_base.captured_by == player_id:
				types[cell.transition_base.type] = true
	return types


func is_volcanic_kernel_captured_by(player_id: String) -> bool:
	var map: GameMap = levels.get(3)
	if map == null:
		return false
	for cell: MapCell in map.cells:
		if cell.content == CellContentType.Value.VOLCANIC_KERNEL and cell.collected_by == player_id:
			return true
	return false
