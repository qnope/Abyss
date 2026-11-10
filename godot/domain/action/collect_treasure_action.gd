class_name CollectTreasureAction
extends Action
## lib/domain/action/collect_treasure_action.dart: searches a revealed
## treasure, ruins or wreck, once, adding its loot (with the research's loot
## bonus) up to the storage cap.

## Treasures and ruins are rarer, so each one is worth more.
const REWARD_MULTIPLIER := TreasureLoot.REWARD_MULTIPLIER

## What may be collected; anything else has nothing to give.
const COLLECTABLE: Array[CellContentType.Value] = [
	CellContentType.Value.RESOURCE_BONUS, CellContentType.Value.RUINS, CellContentType.Value.WRECK,
]

var target_x: int
var target_y: int
var level: int
var random: DartRandom
## What was searched, once executed (a CellContentType.Value or null): it
## decides the noise made.
var _searched: Variant = null


## `random_` null rolls a generator of its own (`Random()`).
func _init(target_x_: int, target_y_: int, level_ := 1, random_: DartRandom = null) -> void:
	target_x = target_x_
	target_y = target_y_
	level = level_
	random = random_ if random_ != null else DartRandom.unseeded()


func type() -> ActionType.Value:
	return ActionType.Value.COLLECT_TREASURE


func description() -> String:
	return "Collecter (%d, %d)" % [target_x, target_y]


func validate(game: Game, player: Player) -> ActionResult:
	var map: GameMap = game.levels.get(level)
	if map == null:
		return CollectTreasureResult.failure(ActionFailure.Value.MAP_NOT_GENERATED)
	var cell := map.cell_at(target_x, target_y)
	if not player.revealed_cells_set_on_level(level).has(Vector2i(target_x, target_y)):
		return CollectTreasureResult.failure(ActionFailure.Value.CELL_NOT_REVEALED)
	if cell.collected_by != null:
		return CollectTreasureResult.failure(ActionFailure.Value.ALREADY_COLLECTED)
	if not COLLECTABLE.has(cell.content):
		return CollectTreasureResult.failure(ActionFailure.Value.NOTHING_TO_COLLECT)
	return CollectTreasureResult.success({})


func execute(game: Game, player: Player) -> ActionResult:
	var validation := validate(game, player)
	if not validation.is_success:
		return validation
	var map: GameMap = game.levels[level]
	var cell := map.cell_at(target_x, target_y)
	var percent := TechEffects.of(player).loot_percent()
	var loot := TreasureLoot.of(cell.content, random, level)
	var deltas: Dictionary[ResourceType.Value, int] = {}
	for type_: ResourceType.Value in loot:
		deltas[type_] = _add_resource(player, type_, DartMath.trunc_div(loot[type_] * percent, 100))
	map.set_cell(target_x, target_y, cell.copy_with({"collected_by": player.id}))
	_searched = cell.content
	if cell.content == CellContentType.Value.WRECK:
		WreckEffect.searched(player, GridPosition.new(target_x, target_y))
	return CollectTreasureResult.success(deltas)


## Adds `amount` of `type_` up to the storage cap; returns what was added.
func _add_resource(player: Player, type_: ResourceType.Value, amount: int) -> int:
	var resource: GameResource = player.resources[type_]
	var before := resource.amount
	resource.amount = clampi(resource.amount + amount, 0, resource.max_storage)
	return resource.amount - before


func make_history_entry(_game: Game, _player: Player, result: ActionResult, turn: int) -> HistoryEntry:
	var collected: CollectTreasureResult = result
	return CollectEntry.new(turn, target_x, target_y, collected.deltas)


## Searching a wreck is loud; treasures and ruins are silent.
func noise_made(_player: Player) -> int:
	return EventRules.WRECK_NOISE if _searched == CellContentType.Value.WRECK else 0
