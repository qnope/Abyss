class_name TipTriggers
extends RefCounted
## lib/domain/objective/tip/tip_triggers.dart: the situations the tip cards
## explain, read from the state of a game. Each check is cheap: a few
## fields, or one pass over the cells the player revealed.


## A quarter of the gauge: noisy enough to be worth explaining, late enough
## not to crowd the first lessons of the tutorial.
static func noise(_game: Game, player: Player) -> bool:
	return player.raid_state.noise >= DartMath.trunc_div(NoiseRules.THRESHOLD, 4)


## The headquarters opened a second building site.
static func worksites(_game: Game, player: Player) -> bool:
	return player.buildings[BuildingType.Value.HEADQUARTERS].level >= WorksiteRules.EXTRA_SITE_AT_HQ[0]


## A branch offers its first choice: its node 1 is researched.
static func tech_choice(_game: Game, player: Player) -> bool:
	for branch: TechBranchState in player.tech_branches.values():
		if branch.unlocked and branch.research_level >= 1:
			return true
	return false


static func raid_announced(_game: Game, player: Player) -> bool:
	return player.raid_state.is_incoming()


## A raid was fought on the base, won or lost.
static func raid_fought(_game: Game, player: Player) -> bool:
	return player.raid_state.raids_repelled + player.raid_state.raids_lost > 0


## Losing one more raid in a row makes the base fall.
static func last_chance(_game: Game, player: Player) -> bool:
	return player.raid_state.lost_in_a_row >= DefeatChecker.LOST_RAIDS_LIMIT - 1


static func lair(game: Game, player: Player) -> bool:
	return _revealed(game, player, func(cell: MapCell) -> bool:
		return cell.content == CellContentType.Value.MONSTER_LAIR)


## A lair of a monster family revealed, not the generic monsters.
static func monster_family(game: Game, player: Player) -> bool:
	return _revealed(game, player, func(cell: MapCell) -> bool:
		return cell.content == CellContentType.Value.MONSTER_LAIR and cell.lair != null and cell.lair.family != null)


## A faction attacked the base: it strikes without warning, so the tip comes
## after the first attack.
static func faction_attack(_game: Game, player: Player) -> bool:
	for entry: HistoryEntry in player.history_entries:
		if entry is BaseAssaultEntry:
			var assault: BaseAssaultEntry = entry
			if assault.defending and assault.post_name == null:
				return true
	return false


static func volcano_wave(_game: Game, player: Player) -> bool:
	return player.volcano_state.is_incoming()


static func chest_or_ruins(game: Game, player: Player) -> bool:
	return _revealed(game, player, func(cell: MapCell) -> bool:
		return cell.content == CellContentType.Value.RESOURCE_BONUS or cell.content == CellContentType.Value.RUINS)


static func transition_base(game: Game, player: Player) -> bool:
	return _revealed(game, player, func(cell: MapCell) -> bool:
		return cell.content == CellContentType.Value.TRANSITION_BASE)


## The descent module built; a save older than it has none.
static func descent(_game: Game, player: Player) -> bool:
	return Building.level_in(player.buildings, BuildingType.Value.DESCENT_MODULE) >= 1


## A first random event was drawn.
static func event(_game: Game, player: Player) -> bool:
	return player.event_state.events_seen > 0


## The trigger of the event `type`: it is the last one drawn.
static func drawn(type: RandomEventType.Value) -> Callable:
	return func(_game: Game, player: Player) -> bool:
		return player.event_state.last_drawn == type


## Whether a cell revealed to `player`, on any level, matches `test`.
static func _revealed(game: Game, player: Player, test: Callable) -> bool:
	for level: int in player.revealed_cells_per_level:
		var map: GameMap = game.levels.get(level)
		if map == null:
			continue
		var cells: Array[GridPosition] = player.revealed_cells_per_level[level]
		for position: GridPosition in cells:
			var matches: bool = test.call(map.cell_at(position.x, position.y))
			if matches:
				return true
	return false
