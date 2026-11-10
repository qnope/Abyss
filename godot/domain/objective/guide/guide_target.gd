class_name GuideTarget
extends RefCounted
## lib/domain/objective/guide/guide_target.dart: what the guide's halo
## surrounds: the `area` of the screen to open, then the item to touch there
## (a card, a cell of the map); or the button that ends the turn.
##
## Its named constructors, named as its fields, take `for_` (domain/README.md).

## Place to open first (a GuideArea.Value), null for the end of the turn.
var area: Variant
## Building whose card is surrounded, on the base (a BuildingType.Value).
var building: Variant
## Unit whose card is surrounded, in the army (a UnitType.Value).
var unit: Variant
## Whether the button that ends the turn is surrounded.
var end_turn: bool
## Level of the map whose `cell` is surrounded (an int), null for no cell.
var level: Variant
## Cell of the map surrounded, on `level`.
var cell: GridPosition
## Whether the button of the sheet of the kernel at `cell` that fills its garrison is.
var garrison: bool
## Branches whose medallion (`_tech_level` 0) or first node (1) is surrounded.
var _branches: Dictionary[TechBranch.Value, bool]
var _tech_level: int


func _init(
	area_: Variant, building_: Variant = null, unit_: Variant = null, branches: Dictionary[TechBranch.Value, bool] = {},
	tech_level := 0, end_turn_ := false, level_: Variant = null, cell_: GridPosition = null, garrison_ := false,
) -> void:
	area = area_
	building = building_
	unit = unit_
	_branches = branches
	_tech_level = tech_level
	end_turn = end_turn_
	level = level_
	cell = cell_
	garrison = garrison_


## `GuideTarget.building`: the card of `type`, on the base.
static func for_building(type: BuildingType.Value) -> GuideTarget:
	return GuideTarget.new(GuideArea.Value.BASE, type)


## `GuideTarget.unit`: the card of `type`, in the army.
static func for_unit(type: UnitType.Value) -> GuideTarget:
	return GuideTarget.new(GuideArea.Value.ARMY, null, type)


## `GuideTarget.map`: the map, to explore it.
static func for_map() -> GuideTarget:
	return GuideTarget.new(GuideArea.Value.MAP)


## `GuideTarget.cell`: the cell `at` of `on_level`, such as a post to take.
static func for_cell(on_level: int, at: GridPosition) -> GuideTarget:
	return GuideTarget.new(GuideArea.Value.MAP, null, null, {}, 0, false, on_level, at)


## `GuideTarget.garrison`: the kernel at `kernel` on `on_level`, then its button.
static func for_garrison(on_level: int, kernel: GridPosition) -> GuideTarget:
	return GuideTarget.new(GuideArea.Value.MAP, null, null, {}, 0, false, on_level, kernel, true)


## `GuideTarget.unlock`: the medallions of `branches`, to unlock one.
static func for_unlock(branches: Dictionary[TechBranch.Value, bool]) -> GuideTarget:
	return GuideTarget.new(GuideArea.Value.RESEARCH, null, null, branches)


## `GuideTarget.research`: the first node of `branches`, to research it.
static func for_research(branches: Dictionary[TechBranch.Value, bool]) -> GuideTarget:
	return GuideTarget.new(GuideArea.Value.RESEARCH, null, null, branches, 1)


## `GuideTarget.endTurn`: the button that ends the turn.
static func for_end_turn() -> GuideTarget:
	return GuideTarget.new(null, null, null, {}, 0, true)


func is_building(type: BuildingType.Value) -> bool:
	return building == type


func is_unit(type: UnitType.Value) -> bool:
	return unit == type


## Whether the cell (`x`, `y`) of the map of `on_level` is surrounded.
func is_cell(on_level: int, x: int, y: int) -> bool:
	return level == on_level and cell != null and cell.x == x and cell.y == y


## Whether the medallion of `branch` is surrounded.
func is_branch(branch: TechBranch.Value) -> bool:
	return _tech_level == 0 and _branches.has(branch)


## Whether the node of `branch` at `node_level` is surrounded.
func is_tech_node(branch: TechBranch.Value, node_level: int) -> bool:
	return _tech_level > 0 and node_level == _tech_level and _branches.has(branch)


## `operator ==`: the same fields, the branches whatever their order.
func equals(other: Variant) -> bool:
	if not other is GuideTarget:
		return false
	var target: GuideTarget = other
	return (
		target.area == area and target.building == building and target.unit == unit
		and target._tech_level == _tech_level and target.end_turn == end_turn
		and target.level == level and target.garrison == garrison
		and (target.cell == null and cell == null or target.cell != null and target.cell.equals(cell))
		and target._branches.size() == _branches.size() and target._branches.has_all(_branches.keys())
	)


## `hashCode`: the same for equal targets, though not Dart's number.
func hash_code() -> int:
	var branches := _branches.keys()
	branches.sort()
	var at: Variant = null if cell == null else cell.key()
	return hash([area, building, unit, _tech_level, end_turn, level, at, garrison, branches])


func _to_string() -> String:
	var place := "endTurn" if area == null else _name(GuideArea.Value, area)
	return "GuideTarget(%s, %s%s)" % [place, _item(), "" if level == null else " on %d" % level]


## The building, the unit, the cell or the branches, the first that is there.
func _item() -> String:
	if building != null:
		return _name(BuildingType.Value, building)
	if unit != null:
		return _name(UnitType.Value, unit)
	if cell != null:
		return str(cell)
	var names := PackedStringArray()
	for branch: TechBranch.Value in _branches:
		names.append(DartEnum.name_of(TechBranch.Value, branch))
	return "(%s)" % ", ".join(names)


static func _name(enumeration: Dictionary, value: Variant) -> String:
	var number: int = value
	return DartEnum.name_of(enumeration, number)
