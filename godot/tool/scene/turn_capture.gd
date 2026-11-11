extends SceneTree
## Renders the end of a turn and of a game for review, as a phone held upright
## shows them. tool/scene_capture.sh runs it:
##   godot --path godot --resolution 780x1688 --script res://tool/scene/turn_capture.gd -- <out dir>
## writes <out dir>/turn_confirm.png (the question of a turn that will shut
## buildings down and take units), turn_summary.png (what it did),
## turn_summary_en.png (the same after the language changed), turn_defeat.png
## and turn_victory.png (the two screens of a game's end, after a few turns),
## each with its draw calls and primitives. The save goes under user:// and is
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
		printerr("usage: turn_capture.gd -- <out dir>")
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
	for turn in 3:
		_end_turn()
	_run_dry(game)
	_app.flow.controller.end_turn.request()
	await _shot("turn_confirm")
	_confirm()
	await _shot("turn_summary")
	TranslationServer.set_locale("en")
	await _shot("turn_summary_en")
	TranslationServer.set_locale("fr")
	_app.modals.close_top()
	game.status = GameStatus.Value.VICTORY
	_app.modals.open(GameOverScreens.victory(game))
	await _shot("turn_victory")
	_app.modals.close_top()
	game.status = GameStatus.Value.DEFEAT
	game.human_player().history_entries.append(HistorySamples.raid_entry(false))
	_app.flow.show_defeat(game)
	await _shot("turn_defeat")
	_folder.remove()
	quit(0)


## A base that makes everything a first economy needs, with scouts to feed.
func _game() -> Game:
	var game := GameFactory.new_single_player("Nemo", 1)
	var player := game.human_player()
	var levels: Dictionary[BuildingType.Value, int] = {
		Type.HEADQUARTERS: 3, Type.ALGAE_FARM: 3, Type.CORAL_MINE: 3, Type.SOLAR_PANEL: 3,
		Type.ORE_EXTRACTOR: 3,
	}
	for type in levels:
		player.buildings[type].level = levels[type]
	KernelGarrison.stock_at(player, 1)[UnitType.Value.SCOUT].count = 10
	return game


## Presses "next turn" and "confirm", then closes what the turn tells.
func _end_turn() -> void:
	_app.flow.controller.end_turn.request()
	_confirm()
	while _app.modals.depth() > 0:
		_app.modals.close_top()


func _confirm() -> void:
	(_app.modals.top() as TurnConfirmation).confirm_button.pressed.emit()


## The farm and the panels stopped, nothing to eat nor to power the mines.
func _run_dry(game: Game) -> void:
	var player := game.human_player()
	player.buildings[Type.ALGAE_FARM].level = 0
	player.buildings[Type.SOLAR_PANEL].level = 0
	player.resources[ResourceType.Value.ALGAE].amount = 0
	player.resources[ResourceType.Value.ENERGY].amount = 0


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
