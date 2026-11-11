class_name PostControllerCase
extends FightControllerCase
## The base of the tests of the posts and the volcano through the game screen
## (game_screen_transition_fight_flow_test.dart, game_screen_garrison_kernel_test.dart):
## the screen of FightControllerCase, with the Faille of the first level and
## the volcano of the third seen, and an army with its Abyss Admiral on each.

const Admiral := UnitType.Value.ABYSS_ADMIRAL
const Guardian := UnitType.Value.GUARDIAN
const VOLCANO := KernelGarrison.VOLCANO_LEVEL

## The cell of the Faille on the first level, and of the volcano's anchor.
var faille_at: Vector2i
var kernel_at: Vector2i


func before_each() -> void:
	super()
	faille_at = _find(1, CellContentType.Value.TRANSITION_BASE)
	kernel_at = _find(VOLCANO, CellContentType.Value.VOLCANIC_KERNEL)
	human.add_revealed_cell(1, GridPosition.new(faille_at.x, faille_at.y))
	human.add_revealed_cell(VOLCANO, GridPosition.new(kernel_at.x, kernel_at.y))
	give({Scout: 3, Harpoonist: 150, Guardian: 100, Admiral: 1})
	human.units_per_level[VOLCANO] = DomainSamples.units({Harpoonist: 150, Guardian: 100, Admiral: 1})
	session.changed.emit()


func faille() -> TransitionBase:
	return game.levels[1].cell_at(faille_at.x, faille_at.y).transition_base


## A touch on the Faille, "Assaut", and the page of the army.
func open_assault() -> ArmySelection:
	world.map.cell_tapped.emit(1, faille_at.x, faille_at.y)
	press("Assaut")
	return current_modal() as ArmySelection


## A touch on the volcano, "launch the assault", and the page of the army.
func open_kernel_assault() -> ArmySelection:
	world.map.cell_tapped.emit(VOLCANO, kernel_at.x, kernel_at.y)
	press("Lancer l'assaut")
	return current_modal() as ArmySelection


## Picks the Admiral and [param count] units of [param type], and presses "launch".
func assault(page: ArmySelection, type: UnitType.Value, count: int) -> void:
	page.rows[Admiral].set_value(1)
	page.rows[type].set_value(count)
	press("Lancer l'assaut")


## The Faille is the player's, with its Descent Module raised.
func hold_faille() -> void:
	faille().captured_by = human.id
	human.buildings[BuildingType.Value.DESCENT_MODULE] = Building.new(BuildingType.Value.DESCENT_MODULE, 1)
	session.changed.emit()


## The volcano is the player's, its kernel raised to [param level].
func hold_kernel(level: int) -> void:
	var cell := game.levels[VOLCANO].cell_at(kernel_at.x, kernel_at.y)
	game.levels[VOLCANO].set_cell(kernel_at.x, kernel_at.y, cell.copy_with({"collected_by": human.id}))
	human.buildings[BuildingType.Value.VOLCANIC_KERNEL] = Building.new(BuildingType.Value.VOLCANIC_KERNEL, level)
	session.changed.emit()


## How many units of [param type] serve on [param level].
func on_level(level: int, type: UnitType.Value) -> int:
	return human.units_on_level(level)[type].count


func _find(level: int, content: CellContentType.Value) -> Vector2i:
	var map: GameMap = game.levels[level]
	var found := Vector2i.ZERO
	for y: int in map.height:
		for x: int in map.width:
			if map.cell_at(x, y).content == content:
				found = Vector2i(x, y)
	return found
