class_name GuideSamples
extends RefCounted
## What the tests of the guide take from test/helpers/guide_helpers.dart and
## guide_campaign_helpers.dart: a game on an objective of the tutorial or of
## the campaign, a post or the kernel placed and seen, an admiral fallen,
## and what the guide says.


## `guideGame`: a fresh ObjectiveSamples game with the tutorial on when
## `tutorial`, its player on objective `id`: every objective of the
## tutorial before it is completed.
static func guide_game(id: ObjectiveId.Value, tutorial := true) -> Game:
	return _on(ObjectiveSamples.objective_game(), InstallationObjectives.installation_objectives(), id, tutorial)


## `campaignGame`: the same with plain maps on levels 1 to 3, its player on
## the campaign objective `id`: every objective before it is completed.
static func campaign_game(id: ObjectiveId.Value, tutorial := true) -> Game:
	var game := ObjectiveSamples.objective_game()
	game.levels = {
		1: ObjectiveSamples.plain_map(), 2: ObjectiveSamples.plain_map(), 3: ObjectiveSamples.plain_map(),
	}
	return _on(game, ObjectiveCatalog.all(), id, tutorial)


static func _on(game: Game, objectives: Array[Objective], id: ObjectiveId.Value, tutorial: bool) -> Game:
	var completed: Array[ObjectiveId.Value] = []
	for objective: Objective in objectives:
		if objective.id == id:
			break
		completed.append(objective.id)
	game.human_player().saved_objective_state = ObjectiveState.new(completed, tutorial)
	return game


## `adviceOf`: what the guide tells the human player of `game`.
static func advice_of(game: Game) -> GuideAdvice:
	return GuideAdvisor.of(game, game.human_player())


## `reveal`: shows the cell (`x`, `y`) of `level` to the human player.
static func reveal(game: Game, level: int, x: int, y: int) -> void:
	var player := game.human_player()
	if not player.revealed_cells_per_level.has(level):
		player.revealed_cells_per_level[level] = [] as Array[GridPosition]
	player.revealed_cells_per_level[level].append(GridPosition.new(x, y))


## `placePost`: a post of `type` at (`x`, `y`) on `level`, held by the human
## player when `held`, seen by them unless `hidden`.
static func place_post(
	game: Game, level: int, x: int, y: int, type := TransitionBaseType.Value.FAILLE, held := false,
	hidden := false,
) -> void:
	var name := DartEnum.name_of(TransitionBaseType.Value, type) + ":0"
	var post := TransitionBase.new(type, name, game.human_player_id if held else null)
	game.levels[level].set_cell(x, y, MapCell.new(
		TerrainType.Value.PLAIN, CellContentType.Value.TRANSITION_BASE, null, null, post))
	if not hidden:
		reveal(game, level, x, y)


## `placeKernel`: the volcanic kernel at (`x`, `y`) on level 3, seen by the
## human player and held by them when `held`.
static func place_kernel(game: Game, x: int, y: int, held := false) -> void:
	game.levels[3].set_cell(x, y, MapCell.new(
		TerrainType.Value.PLAIN, CellContentType.Value.VOLCANIC_KERNEL, null,
		game.human_player_id if held else null))
	reveal(game, 3, x, y)


## `recordAdmiralFell`: an assault on `name` won on `turn` while the
## admiral fell.
static func record_admiral_fell(game: Game, name: String, turn: int) -> void:
	game.human_player().history_entries.append(CaptureEntry.new(turn, name, HistorySamples.fight(true), false))
