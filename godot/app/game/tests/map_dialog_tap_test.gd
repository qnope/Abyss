extends UiTestCase
## A touch on the map while a sheet is open closes the sheet and opens nothing:
## the player taps again to open another cell. The input is the real one, a
## click or a finger pushed through the viewport, over the map's camera and the
## modal layer (the scrim takes the press, the release comes after).

var _folder: TempFolder
var _session: GameSession
var _world: WorldHost
var _hud: GameHud
var _controller: GameController


func before_each() -> void:
	host().size = host().get_viewport().get_visible_rect().size
	# The window of the real app lets the touches through to the world behind.
	host().mouse_filter = Control.MOUSE_FILTER_IGNORE
	_folder = TempFolder.new()
	add_cleanup(_folder.remove)
	var game := GameFactory.new_game("Nemo", 1, Difficulty.Value.NORMAL, false, 2, null, "me")
	_session = GameSession.new(game, GameRepository.new(_folder.path.path_join("saves")))
	_world = WorldHost.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(_world)
	add_cleanup(_world.free)
	_hud = GameHud.new(_session.actions, LanguageChoice.Value.FRENCH, modals())
	mount(_hud)
	_controller = GameController.new(_session, _hud, _world, modals())
	add_cleanup(func() -> void: _controller = null)
	_world.frame_between(0.15, 0.15)
	_world.set_drifting(false)
	press("Carte")


func test_a_click_on_the_map_opens_a_sheet() -> void:
	_click(_on_the_map(), true)
	_click(_on_the_map(), false)
	assert_eq(modals().depth(), 1)


func test_a_click_on_the_scrim_closes_the_sheet_and_opens_no_other() -> void:
	_click(_on_the_map(), true)
	_click(_on_the_map(), false)
	_click(_outside_the_sheet(), true)
	_click(_outside_the_sheet(), false)
	assert_eq(modals().depth(), 0)


func test_a_finger_on_the_scrim_closes_the_sheet_and_opens_no_other() -> void:
	_finger(_on_the_map(), true)
	_finger(_on_the_map(), false)
	assert_eq(modals().depth(), 1)
	_finger(_outside_the_sheet(), true)
	_finger(_outside_the_sheet(), false)
	assert_eq(modals().depth(), 0)


func test_the_next_click_opens_a_sheet_again() -> void:
	_click(_on_the_map(), true)
	_click(_on_the_map(), false)
	_click(_outside_the_sheet(), true)
	_click(_outside_the_sheet(), false)
	_click(_on_the_map(), true)
	_click(_on_the_map(), false)
	assert_eq(modals().depth(), 1)


## Where the middle cell of the map is on the screen, the cell a tap picks.
func _on_the_map() -> Vector2:
	var state := _world.map.state
	var cell := MapGrid.at(state.map.width / 2, state.map.height / 2, state.map.width, state.map.height)
	return _world.map.camera.unproject_position(_world.map.to_global(cell))


## A point of the scrim, far from the sheet, on the map as well.
func _outside_the_sheet() -> Vector2:
	return _on_the_map() + Vector2(0.0, 12.0)


func _click(at: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = host().get_viewport().get_final_transform() * at
	host().get_viewport().push_input(event)


## A finger, with the mouse the engine emulates from it, as a phone sends it.
func _finger(at: Vector2, pressed: bool) -> void:
	var touch := InputEventScreenTouch.new()
	touch.position = host().get_viewport().get_final_transform() * at
	touch.pressed = pressed
	host().get_viewport().push_input(touch)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = pressed
	click.position = touch.position
	click.device = InputEvent.DEVICE_ID_EMULATION
	host().get_viewport().push_input(click)
