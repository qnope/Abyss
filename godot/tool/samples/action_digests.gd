class_name ActionDigests
extends RefCounted
## The short texts the digest test of the actions compares with what a
## scratch Dart script printed on the same games, and the targets it picks.
## Each text writes what the Dart script writes, in its order.


## `type ok|reason | stocks | units of level 1 | units per level |
## buildings | rN cN LN nN eN@x,y uN hN last entry`: the result of an
## action, the stocks in their order, the units of level 1 and the
## buildings that are not at 0, the sum of each level's units, the cells
## revealed and collected on level 1, the levels, the noise, the pending
## explorations (the last one's target), the pending reinforcements and the
## history entries.
static func digest(game: Game, player: Player, action: Action, result: ActionResult) -> String:
	var reason: int = -1 if result.is_success else result.reason
	var outcome := "ok" if result.is_success else DartEnum.name_of(ActionFailure.Value, reason)
	var stocks := PackedStringArray()
	for resource: GameResource in player.resources.values():
		stocks.append(str(resource.amount))
	var level_one := player.unit_counts_on_level(1)
	var levels := PackedStringArray()
	for level: int in player.units_per_level:
		var sum := 0
		for unit: Unit in player.units_per_level[level].values():
			sum += unit.count
		levels.append("%d:%d" % [level, sum])
	var buildings: Dictionary[BuildingType.Value, int] = {}
	for building: Building in player.buildings.values():
		if building.level > 0:
			buildings[building.type] = building.level
	var collected := 0
	for cell: MapCell in game.levels[1].cells:
		if cell.collected_by != null:
			collected += 1
	var orders := player.pending_explorations
	var last_order := "" if orders.is_empty() else "@%d,%d" % [orders[-1].target.x, orders[-1].target.y]
	var entries := player.history_entries
	return "%s %s | %s | %s | %s | %s | r%d c%d L%d n%d e%d%s u%d h%d %s" % [
		DartEnum.name_of(ActionType.Value, action.type()), outcome, ",".join(stocks),
		HistoryDigests.counts(level_one, UnitType.Value), ",".join(levels),
		HistoryDigests.counts(buildings, BuildingType.Value), player.revealed_cells_on_level(1).size(),
		collected, game.levels.size(), player.raid_state.noise, orders.size(), last_order,
		player.pending_reinforcements.size(), entries.size(), "-" if entries.is_empty() else entry(entries[-1]),
	]


## `category turn`, then for a fight `V|L winner turns monsters>left | loot
## | dead | wounded` and for a collect its gains, each map as `name:count`.
static func entry(e: HistoryEntry) -> String:
	var head := "%s %d" % [DartEnum.name_of(HistoryEntryCategory.Value, e.category), e.turn]
	if e is CombatEntry:
		var c := e as CombatEntry
		var f := c.fight_result
		return "%s %s %s %d %d>%d | %s | %s | %s" % [
			head, "V" if c.victory else "L", DartEnum.name_of(CombatSide.Value, f.winner), f.turn_count,
			f.initial_monster_count, f.final_monster_count, HistoryDigests.counts(c.loot, ResourceType.Value),
			HistoryDigests.counts(c.dead, UnitType.Value), HistoryDigests.counts(c.wounded, UnitType.Value),
		]
	if e is CollectEntry:
		return "%s %s" % [head, HistoryDigests.counts((e as CollectEntry).gains, ResourceType.Value)]
	return head


## The first action `make` gives, cell by cell, row by row on `map`, that
## `player` may take; `make(0, 0)` when there is none.
static func first(game: Game, player: Player, map: GameMap, make: Callable) -> Action:
	for y: int in map.height:
		for x: int in map.width:
			var action: Action = make.call(x, y)
			if action.validate(game, player).is_success:
				return action
	var fallback: Action = make.call(0, 0)
	return fallback


## The first transition base of `map`, row by row; (-1, -1) when there is
## none (every game of the digest has one).
static func first_base(map: GameMap) -> Vector2i:
	var base := Vector2i(-1, -1)
	for y: int in map.height:
		for x: int in map.width:
			if base.x < 0 and map.cell_at(x, y).content == CellContentType.Value.TRANSITION_BASE:
				base = Vector2i(x, y)
	return base
