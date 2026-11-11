class_name BuildingTestCase
extends UiTestCase
## The base of the tests of a building's sheet and its parts: a new game with
## its actions, and helpers to set the base up and open a sheet.

var game: Game
var human: Player
var actions: GameActions


func before_each() -> void:
	game = GameFactory.new_single_player("Nemo", 1)
	human = game.human_player()
	actions = GameActions.new(game)


## Puts the buildings at the levels given, the others as they were.
func set_levels(levels: Dictionary[BuildingType.Value, int]) -> void:
	for type: BuildingType.Value in levels:
		human.buildings[type].level = levels[type]


## Fills every store to the brim.
func fill_stores() -> void:
	for resource: GameResource in human.resources.values():
		resource.amount = resource.max_storage


## The sheet of [param type] open on the modals.
func open_sheet(type: BuildingType.Value) -> BuildingSheet:
	var sheet := BuildingSheet.new(actions, type)
	modals().open(sheet)
	return sheet


## The view of [param type] in the game as it stands.
func view_of(type: BuildingType.Value) -> BuildingView:
	return BuildingView.of(game, type)


## The nodes under [param root] made from the script [param script] that are
## visible (a ShieldBadge, a WorksiteBadge...).
func shown(root: Node, script: Script) -> Array[Node]:
	return root.find_children("*", "Control", true, false).filter(func(node: Node) -> bool:
		return node.get_script() == script and (node as Control).is_visible_in_tree())


## The row of an upgrade's list under [param root] whose label is
## [param label], or null.
func requirement(root: Node, label: String) -> RequirementRow:
	for node in shown(root, RequirementRow):
		var row := node as RequirementRow
		if row.label.text == label:
			return row
	return null
