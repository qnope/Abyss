class_name FactionStanding
extends RefCounted
## lib/domain/faction/faction_standing.dart: what the human knows of a
## player in the ranking: only public facts, the headquarters level and how
## deep the player holds a post. Ported ahead of its module for the
## Archives of the objectives (`is_discovered_by`).

var name: String
## A FactionPersonality.Value, null for the human player.
var personality: Variant
var headquarters_level: int
## Deepest level where the player holds a post (1 when none).
var deepest_level: int
var holds_kernel: bool
var has_fallen: bool
## Whether the human has seen the player's base; always for the human.
var discovered: bool


func _init(
	name_: String,
	personality_: Variant,
	headquarters_level_: int,
	deepest_level_: int,
	holds_kernel_: bool,
	has_fallen_: bool,
	discovered_: bool,
) -> void:
	name = name_
	personality = personality_
	headquarters_level = headquarters_level_
	deepest_level = deepest_level_
	holds_kernel = holds_kernel_
	has_fallen = has_fallen_
	discovered = discovered_


func is_human() -> bool:
	return personality == null


## `FactionStanding.of`: the standing of `player` in `game`.
static func of(game: Game, player: Player) -> FactionStanding:
	var kernel := game.is_volcanic_kernel_captured_by(player.id)
	var deepest := 3 if kernel else 1
	for map: GameMap in game.levels.values():
		for cell: MapCell in map.cells:
			var base := cell.transition_base
			if base != null and base.captured_by == player.id and base.target_level() > deepest:
				deepest = base.target_level()
	var personality_: Variant = null
	for faction: Faction in game.factions():
		if faction.id() == player.id:
			personality_ = faction.personality
			break
	return FactionStanding.new(
		player.name,
		personality_,
		player.buildings[BuildingType.Value.HEADQUARTERS].level,
		deepest,
		kernel,
		player.has_fallen(),
		is_discovered_by(game.human_player(), player),
	)


## Whether `viewer` has revealed the base cell of `player`; always for its
## own base.
static func is_discovered_by(viewer: Player, player: Player) -> bool:
	if player.id == viewer.id:
		return true
	var base := Vector2i(player.base_x, player.base_y)
	return GridPosition.keys(viewer.revealed_cells_on_level(RaidBattle.BASE_LEVEL)).has(base)


## The human and the factions, the most advanced first (kernel, depth,
## headquarters); the fallen last. Empty in a game without factions.
static func ranking(game: Game) -> Array[FactionStanding]:
	if game.factions().is_empty():
		return []
	var standings: Array[FactionStanding] = [of(game, game.human_player())]
	for faction: Faction in game.factions():
		if game.players.has(faction.id()):
			standings.append(of(game, game.players[faction.id()]))
	# Stable: equal scores keep the playing order, the human first.
	var indexed: Array[int] = []
	for index: int in standings.size():
		indexed.append(index)
	DartSort.sort(indexed, func(a: int, b: int) -> int:
		var by_score := DartSort.compare_ints(_score(standings[b]), _score(standings[a]))
		return by_score if by_score != 0 else DartSort.compare_ints(a, b))
	var sorted: Array[FactionStanding] = []
	for index: int in indexed:
		sorted.append(standings[index])
	return sorted


static func _score(s: FactionStanding) -> int:
	return (
		(0 if s.has_fallen else 1000) + (100 if s.holds_kernel else 0)
		+ s.deepest_level * 20 + s.headquarters_level
	)
