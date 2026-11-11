class_name FactionControllerCase
extends PostControllerCase
## The base of the tests of the rival factions through the game screen
## (game_screen_faction_actions_test.dart, game_screen_rival_fight_flow_test.dart):
## the screen of PostControllerCase at turn 12, the tutorial over, the base of
## the first faction seen, and the Scouts and the army to strike it with.

var rival: Player
var rival_at: Vector2i


func before_each() -> void:
	super()
	game.turn = 12
	ObjectiveMigration.state_of(game, human).tutorial_enabled = false
	rival = game.players[game.factions()[0].id()]
	rival_at = Vector2i(rival.base_x, rival.base_y)
	human.add_revealed_cell(1, GridPosition.new(rival_at.x, rival_at.y))
	session.changed.emit()


## A touch on the base of the faction, and its sheet.
func open_rival() -> FactionBaseSheet:
	world.map.cell_tapped.emit(1, rival_at.x, rival_at.y)
	return current_modal() as FactionBaseSheet


## The sheet, "Attaquer", and the page of the army.
func open_rival_assault() -> ArmySelection:
	open_rival()
	press("Attaquer")
	return current_modal() as ArmySelection


## Picks [param count] units of [param type] and presses "launch".
func strike(page: ArmySelection, type: UnitType.Value, count: int) -> void:
	page.rows[type].set_value(count)
	press("Lancer l'assaut")


## The rival defends its base with a wall nobody beats.
func wall_up() -> void:
	AssaultSamples.station(rival, AssaultSamples.WALL)


## How much of [param type] the rival holds.
func rival_stock(type: ResourceType.Value) -> int:
	return rival.resources[type].amount


## The rival holds the Faille of the first level.
func rival_holds_faille() -> void:
	faille().captured_by = rival.id
	session.changed.emit()


## The rival holds the volcano, its kernel raised to [param level].
func rival_holds_kernel(level: int) -> void:
	var cell := game.levels[VOLCANO].cell_at(kernel_at.x, kernel_at.y)
	game.levels[VOLCANO].set_cell(kernel_at.x, kernel_at.y, cell.copy_with({"collected_by": rival.id}))
	rival.buildings[BuildingType.Value.VOLCANIC_KERNEL] = Building.new(BuildingType.Value.VOLCANIC_KERNEL, level)
	session.changed.emit()


## The assaults [param player] has in its history.
func assaults(player: Player) -> Array[BaseAssaultEntry]:
	var found: Array[BaseAssaultEntry] = []
	for entry in player.history_entries:
		if entry is BaseAssaultEntry:
			found.append(entry as BaseAssaultEntry)
	return found


## Whether [param root] shows a line that contains [param part].
func says(root: Node, part: String) -> bool:
	for shown in texts(root):
		if shown.contains(part):
			return true
	return false
