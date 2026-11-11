extends SceneTree
## Renders the rival factions for review, as a phone held upright shows them.
## tool/scene_capture.sh runs it:
##   godot --path godot --resolution 780x1688 --script res://tool/scene/faction_capture.gd -- <out dir>
## writes <out dir>/faction_sheet.png (a rival base before any intel),
## faction_sheet_intel.png (after a Scout spied on it), faction_selection.png
## (the army of the assault with its plan), faction_report_won.png and
## faction_report_lost.png (the report of the assault, won against a bare base,
## lost against a wall), faction_ranking.png (from the settings) and
## faction_attack_summary.png (a faction attacks the base in the summary of the
## turn), each with its draw calls and primitives. The save goes under user://
## and is removed at the end.

const MainScene := preload("res://app/main.tscn")
const WARM_UP := 120
const SETTLE := 20
const Harpoonist := UnitType.Value.HARPOONIST
const Guardian := UnitType.Value.GUARDIAN
const Admiral := UnitType.Value.ABYSS_ADMIRAL

var _out := ""
var _app: App
var _folder := TempFolder.new()
var _game: Game
var _human: Player
var _rival: Player
var _at: Vector2i


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("usage: faction_capture.gd -- <out dir>")
		quit(2)
		return
	_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	_capture()


func _capture() -> void:
	_start()
	await _frames(WARM_UP)
	_game = MapCaptureGame.of_three_levels()
	_game.turn = 12
	_human = _game.human_player()
	_human.units_per_level[1] = DomainSamples.units({Admiral: 1, Harpoonist: 150, Guardian: 100, UnitType.Value.SCOUT: 3})
	_rival = _game.players[_game.factions()[0].id()]
	_at = Vector2i(_rival.base_x, _rival.base_y)
	_human.add_revealed_cell(1, GridPosition.new(_at.x, _at.y))
	ObjectiveMigration.state_of(_game, _human).tutorial_enabled = false
	_app.flow.play(_game)
	(_app.flow.current as GameHud).show_tab(GameTab.Value.MAP)
	await _sheet_flow()
	await _assault_flow()
	await _ranking_flow()
	await _summary_flow()
	_folder.remove()
	quit(0)


func _sheet_flow() -> void:
	await _tap()
	await _shot("faction_sheet")
	_press("Espionner")
	await _shot("faction_sheet_intel")
	_app.modals.close_top()


func _assault_flow() -> void:
	await _tap()
	_press("Attaquer")
	var page := _app.modals.top() as ArmySelection
	page.rows[Harpoonist].set_value(60)
	page.rows[Guardian].set_value(20)
	await _shot("faction_selection")
	page.launch()
	await _shot("faction_report_won")
	_app.modals.close_top()
	AssaultSamples.station(_rival, AssaultSamples.WALL)
	_game.turn += 1
	await _tap()
	_press("Attaquer")
	var lost := _app.modals.top() as ArmySelection
	lost.rows[Harpoonist].set_value(5)
	lost.launch()
	await _shot("faction_report_lost")
	_app.modals.close_top()


func _ranking_flow() -> void:
	(_app.flow.current as GameHud).open_settings()
	await _frames(1)
	var dialog := _app.modals.top() as SettingsDialog
	dialog.links.ranking_row.pressed.emit()
	await _shot("faction_ranking")
	while _app.modals.depth() > 0:
		_app.modals.close_top()


func _summary_flow() -> void:
	AssaultSamples.station(_human, {})
	AssaultSamples.announce().execute(_game, _rival)
	_app.flow.controller.end_turn.request()
	(_app.modals.top() as TurnConfirmation).confirm_button.pressed.emit()
	await _shot("faction_attack_summary")


func _press(text: String) -> void:
	var found: Control = null
	for node in _app.modals.top().find_children("*", "Button", true, false):
		if (node as Button).text == text and (node as Button).is_visible_in_tree():
			found = node as Control
	(found as Button).pressed.emit()


func _tap() -> void:
	_app.world.map.cell_tapped.emit(1, _at.x, _at.y)
	await _frames(1)


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
