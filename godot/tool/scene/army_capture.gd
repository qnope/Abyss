extends SceneTree
## Renders the army tab for review, as a phone held upright shows it.
## tool/scene_capture.sh runs it:
##   godot --path godot --resolution 780x1688 --script res://tool/scene/army_capture.gd -- <out dir>
## writes <out dir>/army_parade.png (the parade ground of an army in two
## places, recruits possible, one squad locked), army_places.png (the second
## level only, the bar of places), army_close.png (a closer view of the
## squads and their plaques), army_barracks_empty.png (no barracks yet),
## army_sheet_unit.png and army_sheet_recruit.png (the sheet of a unit, then
## with four to recruit), army_sheet_locked.png (a unit the barracks is too
## low for) and army_reinforcement.png and army_picker.png (the dialogs that
## pick units), each with its draw calls and primitives. The save goes under
## user:// and is removed at the end.

const MainScene := preload("res://app/main.tscn")
const WARM_UP := 120
const SETTLE := 20
const Type := UnitType.Value

var _out := ""
var _app: App
var _folder := TempFolder.new()


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("usage: army_capture.gd -- <out dir>")
		quit(2)
		return
	_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	_capture()


func _capture() -> void:
	_start()
	await _frames(WARM_UP)
	var game := _game()
	_app.flow.play(game)
	var hud := _app.flow.current as GameHud
	hud.show_tab(GameTab.Value.ARMY)
	await _shot("army_parade")
	var controller := _app.flow.controller
	controller.army.tab.choose(2)
	await _shot("army_places")
	controller.army.tab.choose(ArmyPlaces.ALL)
	var camera := _app.world.parade.camera
	camera.rig.look(OrbitRig.DEFAULT_YAW + 15.0, -30.0, camera.rig.default_distance * 0.55)
	await _shot("army_close")
	camera.rig.look(OrbitRig.DEFAULT_YAW, OrbitRig.DEFAULT_PITCH, camera.rig.default_distance)
	var sheets: Dictionary[String, UnitType.Value] = {"unit": Type.HARPOONIST, "locked": Type.SABOTEUR}
	for sheet in sheets:
		_app.world.parade.squad_tapped.emit(sheets[sheet])
		await _shot("army_sheet_%s" % sheet)
		if sheet == "unit":
			_four_to_recruit()
			await _shot("army_sheet_recruit")
		_app.modals.close_top()
	await _dialogs(game)
	game.human_player().buildings[BuildingType.Value.BARRACKS].level = 0
	_app.flow.controller.session.actions.mark(func(_game: Game) -> void: pass)
	await _shot("army_barracks_empty")
	_folder.remove()
	quit(0)


func _four_to_recruit() -> void:
	for node in _app.modals.get_children():
		for slider in node.find_children("*", "HSlider", true, false):
			if (slider as HSlider).is_visible_in_tree():
				(slider as HSlider).value = 4


func _dialogs(game: Game) -> void:
	var units := game.human_player().units_on_level(1)
	_app.modals.open(ReinforcementDialog.new(units, 2, "Faille Nord", Portrait.new("Faille Nord", 48.0)))
	await _shot("army_reinforcement")
	_app.modals.close_top()
	_app.modals.open(UnitPickerDialog.new("Garnison", units, "Garnir", "Les unités restent au noyau."))
	await _shot("army_picker")
	_app.modals.close_top()


## A game with an army in two places, a barracks at level 3 (so the admiral
## and the saboteur are still locked), and stock to recruit with.
func _game() -> Game:
	var game := GameFactory.new_single_player("Nemo", 1)
	var player := game.human_player()
	player.buildings[BuildingType.Value.HEADQUARTERS].level = 4
	player.buildings[BuildingType.Value.BARRACKS].level = 3
	player.units_per_level[1] = DomainSamples.units({Type.SCOUT: 12, Type.HARPOONIST: 5, Type.GUARDIAN: 1})
	player.units_per_level[2] = DomainSamples.units({Type.HARPOONIST: 30, Type.DOME_BREAKER: 2})
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
