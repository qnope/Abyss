class_name DescendAction
extends Action
## lib/domain/action/descend_action.dart: takes units down through a post
## the player holds, generating the level below when nobody reached it yet.
##
## Dart puts the new level in a new map assigned to `game.levels`; the port
## adds it to the same dictionary, in the same place.

var transition_x: int
var transition_y: int
var from_level: int
var selected_units: Dictionary[UnitType.Value, int]
## Seeds the map of a level reached for the first time; null draws an
## unseeded one.
var random: DartRandom


func _init(
	transition_x_: int, transition_y_: int, from_level_: int,
	selected_units_: Dictionary[UnitType.Value, int], random_: DartRandom = null,
) -> void:
	transition_x = transition_x_
	transition_y = transition_y_
	from_level = from_level_
	selected_units = selected_units_
	random = random_


func type() -> ActionType.Value:
	return ActionType.Value.DESCEND


func description() -> String:
	return "Descente niveau %d" % from_level


func validate(game: Game, player: Player) -> ActionResult:
	return DescendValidator.validate(game, player, transition_x, transition_y, from_level, selected_units)


func execute(game: Game, player: Player) -> ActionResult:
	var validation := validate(game, player)
	if not validation.is_success:
		return validation
	var cell := game.levels[from_level].cell_at(transition_x, transition_y)
	var target_level := cell.transition_base.target_level()
	if game.levels.get(target_level) == null:
		_generate_target_level(game, target_level)
	if not player.units_per_level.has(target_level):
		_arrive(game, player, target_level)
	_transfer_units(player, target_level)
	var sent: Dictionary[UnitType.Value, int] = {}
	for type_: UnitType.Value in selected_units:
		if selected_units[type_] > 0:
			sent[type_] = selected_units[type_]
	return DescendResult.success(target_level, sent)


func _generate_target_level(game: Game, target_level: int) -> void:
	var passages := PassageExtractor.from(game.levels[from_level])
	var seed_: Variant = random.next_int(0x7FFFFFFF) if random != null else null
	game.levels[target_level] = MapGenerator.generate(seed_, target_level, passages).map


## A player's first arrival on a level: an empty stock of units and a fog
## opened around the passage. Games with factions generate every level at
## the start, so the level may exist before anyone comes.
func _arrive(game: Game, player: Player, target_level: int) -> void:
	var units: Dictionary[UnitType.Value, Unit] = {}
	for type_: UnitType.Value in UnitType.Value.values():
		units[type_] = Unit.new(type_)
	player.units_per_level[target_level] = units
	var map: GameMap = game.levels[target_level]
	player.revealed_cells_per_level[target_level] = RevealAreaCalculator.cells_to_reveal(
		transition_x, transition_y, 5, map.width, map.height
	)
	VolcanoFootprint.reveal_whole(map, player, target_level)


func _transfer_units(player: Player, target_level: int) -> void:
	for type_: UnitType.Value in selected_units:
		var count: int = selected_units[type_]
		if count <= 0:
			continue
		player.units_on_level(from_level)[type_].count -= count
		player.units_on_level(target_level)[type_].count += count


func make_history_entry(_game: Game, _player: Player, result: ActionResult, turn: int) -> HistoryEntry:
	if not result is DescendResult or not result.is_success:
		return null
	var descended: DescendResult = result
	var total := 0
	for count: int in descended.units_sent.values():
		total += count
	var target_level: int = descended.target_level
	return DescentEntry.new(turn, target_level, total)
