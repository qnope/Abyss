class_name SectionChanges
extends RefCounted
## test/domain/reference/section_changes.dart: for each section of a
## snapshot, changes of state it alone must show, on a game against two
## factions whose three levels exist. Each change is a Callable taking the
## Game. The journal records no action yet (`ReplayJournal.record` comes
## with the encoder): its third change writes the text the encoder writes
## for `UpgradeBuildingAction(algaeFarm)`.


## The first faction of `g`.
static func rival_of(g: Game) -> Player:
	return g.players[g.factions()[0].id()]


## Every section's changes, those of LaterSectionChanges included.
static func all() -> Dictionary[String, Array]:
	var changes: Dictionary[String, Array] = {
		"game": [
			func(g: Game) -> void: g.turn += 1,
			func(g: Game) -> void: g.status = GameStatus.Value.FREE_PLAY,
			func(g: Game) -> void: g.saved_difficulty = Difficulty.Value.HARD,
			func(g: Game) -> void: g.saved_factions = [FactionPersonality.Value.MAGMA_SMITHS] as Array[FactionPersonality.Value],
		],
		"journal": [
			func(g: Game) -> void: g.replay.exact = false,
			func(g: Game) -> void: g.replay.end_turn_seeds[1] = 5,
			func(g: Game) -> void: g.replay.actions[1] = ['{"do":"upgrade","building":"algaeFarm"}'] as Array[String],
			func(g: Game) -> void: g.replay = null,
		],
		"leviathan": [
			func(g: Game) -> void: g.leviathan_return.over = true,
			func(g: Game) -> void: g.leviathan_return.schedule("faille-1", 1, GridPosition.new(2, 3), 4),
			func(g: Game) -> void: g.leviathan_return = null,
		],
		"map1": [func(g: Game) -> void: _take(g, 1)],
		"map2": [func(g: Game) -> void: _take(g, 2)],
		"map3": [func(g: Game) -> void: _take(g, 3), func(g: Game) -> void: g.levels.erase(3)],
		"players": [
			func(g: Game) -> void: g.human_player().base_x += 1,
			func(g: Game) -> void: rival_of(g).base_y += 1,
			func(g: Game) -> void: rival_of(g).saved_fallen = true,
		],
		"resources": [
			func(g: Game) -> void: g.human_player().resources[ResourceType.Value.PEARL].amount += 1,
			func(g: Game) -> void: rival_of(g).resources[ResourceType.Value.ALGAE].amount -= 1,
		],
		"buildings": [func(g: Game) -> void: g.human_player().buildings[BuildingType.Value.HEADQUARTERS].level += 1],
		"worksite": [
			func(g: Game) -> void: g.human_player().worksite.upgrades += 1,
			func(g: Game) -> void: rival_of(g).worksite.research += 1,
		],
		"tech": [
			func(g: Game) -> void: g.human_player().tech_branches[TechBranch.Value.MILITARY].unlocked = true,
			func(g: Game) -> void: g.human_player().tech_branches[TechBranch.Value.EXPLORER].research_level += 1,
			func(g: Game) -> void: g.human_player().tech_branches[TechBranch.Value.RESOURCES].choose(2, TechOption.Value.B),
		],
		"units": [
			func(g: Game) -> void: g.human_player().units_on_level(1)[UnitType.Value.SCOUT].count += 1,
			func(g: Game) -> void: g.human_player().recruited_unit_types.append(UnitType.Value.SCOUT),
			func(g: Game) -> void: g.human_player().units_per_level[2] = {} as Dictionary[UnitType.Value, Unit],
			# The order of a map is state: the same units, the scout moved last.
			func(g: Game) -> void:
				var units := g.human_player().units_on_level(1)
				var scout: Unit = units[UnitType.Value.SCOUT]
				units.erase(UnitType.Value.SCOUT)
				units[UnitType.Value.SCOUT] = scout,
		],
		"orders": [
			func(g: Game) -> void: g.human_player().pending_explorations.append(ExplorationOrder.new(GridPosition.new(1, 1))),
			func(g: Game) -> void: g.human_player().pending_reinforcements.append(ReinforcementOrder.new(
				1, 2, {UnitType.Value.SCOUT: 1} as Dictionary[UnitType.Value, int], 3, GridPosition.new(4, 5),
			)),
		],
		"fog": [
			func(g: Game) -> void: g.human_player().revealed_cells_on_level(1).pop_back(),
			func(g: Game) -> void: g.human_player().add_revealed_cell(2, GridPosition.new(0, 0)),
			func(g: Game) -> void:
				var cells := g.human_player().revealed_cells_on_level(1)
				cells.append(cells.pop_front()),
		],
	}
	changes.merge(LaterSectionChanges.all())
	return changes


static func _take(g: Game, level: int) -> void:
	var map: GameMap = g.levels[level]
	map.set_cell(1, 0, map.cell_at(1, 0).copy_with({"collected_by": g.human_player_id}))
