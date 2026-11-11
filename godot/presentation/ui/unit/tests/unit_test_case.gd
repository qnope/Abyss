class_name UnitTestCase
extends UiTestCase
## The base of the tests of a unit's sheet: a new game for "Nemo" with a
## barracks at level 1 and 500 of every resource, its actions, and a helper
## to open a sheet.

const Type := UnitType.Value
const Barracks := BuildingType.Value.BARRACKS

var game: Game
var human: Player
var actions: GameActions


func before_each() -> void:
	game = GameFactory.new_single_player("Nemo", 1)
	human = game.human_player()
	human.buildings[Barracks].level = 1
	for resource: GameResource in human.resources.values():
		resource.amount = 500
	actions = GameActions.new(game)


## The sheet of [param type] open on the modals, [param count] serving.
func open_sheet(type: UnitType.Value, count := 0) -> UnitSheet:
	var sheet := UnitSheet.new(actions, type, count)
	modals().open(sheet)
	return sheet


## The units of [param type] at the level [param level] of the map.
func units_at(type: UnitType.Value, level := 1) -> int:
	return human.units_on_level(level)[type].count


## The pictures of units shown under [param root].
func portraits_in(root: Node) -> Array[Portrait]:
	var found: Array[Portrait] = []
	for node in find_type("PanelContainer", root):
		if node is Portrait and (node as Portrait).is_visible_in_tree():
			found.append(node)
	return found


## The first picture of a unit shown under [param root].
func portrait_in(root: Node) -> Portrait:
	return portraits_in(root)[0]


## The recruiting section shown under [param root].
func section_in(root: Node) -> RecruitmentSection:
	for node in find_type("VBoxContainer", root):
		if node is RecruitmentSection and (node as RecruitmentSection).is_visible_in_tree():
			return node
	return null


## The slider of the recruiting section shown under [param root], or null.
func slider_in(root: Node) -> HSlider:
	var section := section_in(root)
	return section.slider if section != null else null
