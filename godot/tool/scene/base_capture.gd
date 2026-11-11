extends SceneTree
## Renders the base and the sheets of its buildings for review, as a phone
## held upright shows them. tool/scene_capture.sh runs it:
##   godot --path godot --resolution 780x1688 --script res://tool/scene/base_capture.gd -- <out dir>
## writes <out dir>/base_standins.png (the eleven pads as stand-ins, in
## several states), base_models.png (the same base with the models there
## are), base_close.png (a closer view of the stand-ins and their marks),
## base_sheet_upgrade.png, base_sheet_degraded.png, base_sheet_citadel.png
## and base_sheet_locked.png (the sheets of a building that can rise, a
## degraded one, the Coral Citadel and one held back by a prerequisite), each
## with its draw calls and primitives. The save goes under user:// and is
## removed at the end.

const MainScene := preload("res://app/main.tscn")
const WARM_UP := 120
const SETTLE := 20
const Type := BuildingType.Value

var _out := ""
var _app: App
var _folder := TempFolder.new()


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("usage: base_capture.gd -- <out dir>")
		quit(2)
		return
	_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	_capture()


func _capture() -> void:
	_start()
	await _frames(WARM_UP)
	var game := _game()
	_app.world.base.buildings.use_models = false
	_app.flow.play(game)
	await _shot("base_standins")
	var camera := _app.world.base.camera
	camera.rig.look(OrbitRig.DEFAULT_YAW + 25.0, -32.0, camera.rig.default_distance * 0.6)
	await _shot("base_close")
	_app.flow.show_menu()
	_app.world.base.buildings.use_models = true
	_app.flow.play(game)
	await _shot("base_models")
	var hud := _app.flow.current as GameHud
	var sheets: Dictionary[String, BuildingType.Value] = {
		"upgrade": Type.CORAL_MINE, "degraded": Type.BARRACKS,
		"citadel": Type.CORAL_CITADEL, "locked": Type.DESCENT_MODULE,
	}
	for sheet in sheets:
		hud.open_building(sheets[sheet])
		await _shot("base_sheet_%s" % sheet)
		_app.modals.close_top()
	_folder.remove()
	quit(0)


## A game whose base shows every state of a pad: a building that can rise at
## each of the three heights, a degraded one, plots to build and one held
## back, with stock to build with.
func _game() -> Game:
	var game := GameFactory.new_single_player("Nemo", 1)
	var player := game.human_player()
	var levels: Dictionary[BuildingType.Value, int] = {
		Type.HEADQUARTERS: 4, Type.ALGAE_FARM: 6, Type.CORAL_MINE: 2, Type.SOLAR_PANEL: 1,
		Type.BARRACKS: 3, Type.CORAL_CITADEL: 3,
	}
	for type in levels:
		player.buildings[type].level = levels[type]
	for resource: GameResource in player.resources.values():
		resource.amount = resource.max_storage
	return game


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
