class_name FightControllerCase
extends UiTestCase
## The base of the tests of the fights through the game screen
## (game_screen_fight_flow_test.dart): the screen of a new game whose first
## level holds a lair next to the base, the player's units on it, and the map
## on show.

const Scout := UnitType.Value.SCOUT
const Harpoonist := UnitType.Value.HARPOONIST

var repository: GameRepository
var session: GameSession
var world: WorldHost
var hud: GameHud
var controller: GameController
var game: Game
var human: Player
## The cell of the lair.
var lair_at: Vector2i
var _folder: TempFolder


func before_each() -> void:
	_folder = TempFolder.new()
	add_cleanup(_folder.remove)
	repository = GameRepository.new(_folder.path.path_join("saves"))
	game = GameFactory.new_game("Nemo", 1, Difficulty.Value.NORMAL, false, 2, null, "me")
	human = game.human_player()
	lair_at = Vector2i(human.base_x + 1, human.base_y)
	put_lair(MonsterLair.new(MonsterDifficulty.Value.EASY, 1))
	give({Scout: 3, Harpoonist: 2})
	session = GameSession.new(game, repository)
	world = WorldHost.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(world)
	add_cleanup(world.free)
	hud = GameHud.new(session.actions, LanguageChoice.Value.FRENCH, modals())
	mount(hud)
	controller = GameController.new(session, hud, world, modals())
	add_cleanup(func() -> void: controller = null)
	# The strikes are over at once: the reports open as the fights end.
	world.map.effects.reduced_motion = true
	world.frame_between(0.15, 0.15)
	press("Carte")


## Puts [param lair] on the lair's cell.
func put_lair(lair: MonsterLair) -> void:
	game.levels[1].set_cell(lair_at.x, lair_at.y, MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.MONSTER_LAIR, lair))


## Leaves the player [param counts] units on the first level.
func give(counts: Dictionary[UnitType.Value, int]) -> void:
	human.units_per_level[1] = DomainSamples.units(counts)


## How many units of [param type] serve on the first level.
func stock(type: UnitType.Value) -> int:
	return human.units_on_level(1)[type].count


## A touch on the lair, "prepare the fight", and the page of the army.
func open_selection() -> ArmySelection:
	world.map.cell_tapped.emit(1, lair_at.x, lair_at.y)
	press("Préparer le combat")
	return current_modal() as ArmySelection


## Picks [param count] units of [param type] and presses "launch".
func send(page: ArmySelection, type: UnitType.Value, count: int) -> void:
	page.rows[type].set_value(count)
	press("Lancer le combat")


func saved() -> Game:
	return repository.load_all().games[0]
