extends SceneTree
## Renders the map tab for review, as a phone held upright shows it.
## tool/scene_capture.sh runs it:
##   godot --path godot --resolution 780x1688 --script res://tool/scene/map_capture.gd -- <out dir>
## writes <out dir>/map_level1.png (the surface of a game against three
## factions, a scout on its way, a ruin and a treasure by the base),
## map_level2.png and map_level3.png (the other depths, seen where a post or
## the volcano lies, the rest in the dark), map_close.png (the camera brought
## close), map_exploration_sheet.png (a hidden
## cell next to the seen ones), map_exploration_storm.png (the same under a
## storm), map_treasure_sheet.png and map_found.png (the search of a ruin,
## then what it gave) and map_visited.png (the cell once searched), each with
## its draw calls and primitives. The save goes under user:// and is removed
## at the end.

const MainScene := preload("res://app/main.tscn")
const WARM_UP := 120
const SETTLE := 20

var _out := ""
var _app: App
var _folder := TempFolder.new()
var _game: Game
var _human: Player


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("usage: map_capture.gd -- <out dir>")
		quit(2)
		return
	_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	_capture()


func _capture() -> void:
	_start()
	await _frames(WARM_UP)
	_game = MapCaptureGame.of_three_levels()
	_human = _game.human_player()
	_app.flow.play(_game)
	var hud := _app.flow.current as GameHud
	hud.show_tab(GameTab.Value.MAP)
	await _shot("map_level1")
	var map := _app.flow.controller.map
	for level: int in [2, 3]:
		map.show_level(level)
		await _shot("map_level%d" % level)
	map.show_level(1)
	var camera := _app.world.map.camera
	await _view(camera, 0.45, "map_close")
	await _view(camera, 1.0, "")
	var hidden := MapCaptureGame.hidden_next_to_the_seen(_game)
	_app.world.map.cell_tapped.emit(1, hidden.x, hidden.y)
	await _shot("map_exploration_sheet")
	_app.modals.close_top()
	_human.event_state.activate(RandomEventType.Value.STORM, _game.turn + 2)
	_app.world.map.cell_tapped.emit(1, hidden.x, hidden.y)
	await _shot("map_exploration_storm")
	_app.modals.close_top()
	await _search()
	_folder.remove()
	quit(0)


## The camera [param factor] times as far as it frames the map, then a shot.
func _view(camera: MapCamera, factor: float, shot_name: String) -> void:
	camera.rig.look(camera.rig.yaw, camera.rig.pitch, camera.rig.default_distance * factor)
	if not shot_name.is_empty():
		await _shot(shot_name)


## The ruins by the base: their sheet, what the search gave, the cell after.
func _search() -> void:
	var at := Vector2i(_human.base_x, _human.base_y) + MapCaptureGame.RUINS_AT
	_app.world.map.cell_tapped.emit(1, at.x, at.y)
	await _shot("map_treasure_sheet")
	var sheet: TreasureSheet = _app.modals.top()
	sheet.collect_button.pressed.emit()
	await _shot("map_found")
	_app.modals.close_top()
	_app.world.map.cell_tapped.emit(1, at.x, at.y)
	await _shot("map_visited")


func _start() -> void:
	TranslationServer.set_locale("fr")
	_app = MainScene.instantiate() as App
	_app.repository = GameRepository.new(_folder.path.path_join("saves"))
	_app.language = LanguageSettings.new(_folder.path.path_join("settings.json"))
	_app.language.choose(LanguageChoice.Value.FRENCH)
	_app.bench = BenchOptions.new(0.0)
	root.add_child(_app)


func _shot(shot_name: String) -> void:
	await _frames(SETTLE)
	var path := _out.path_join("%s.png" % shot_name)
	root.get_texture().get_image().save_png(path)
	print(path)
	print("  draw calls %d, primitives %d, objects %d" % [
		Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
	])


func _frames(count: int) -> void:
	for i in count:
		await process_frame
