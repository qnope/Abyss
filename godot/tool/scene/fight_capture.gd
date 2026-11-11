extends SceneTree
## Renders the fights against the lairs of the map for review, as a phone held
## upright shows them. tool/scene_capture.sh runs it:
##   godot --path godot --resolution 780x1688 --script res://tool/scene/fight_capture.gd -- <out dir>
## writes <out dir>/fight_lair_sheet.png (the sheet of a lair of hunters),
## fight_lair_generic.png (the generic monsters, no rule), fight_selection.png
## (the army page with units picked), fight_selection_en.png (the same in
## English), fight_refused.png (a launch refused: the units picked are gone),
## fight_report_won.png and fight_report_won_end.png (the report of a victory,
## then its end), fight_map_beaten.png (the map after it: the lair dimmed) and
## fight_report_lost.png (the report of a defeat), each with its draw calls and
## primitives. The save goes under user:// and is removed at the end.

const MainScene := preload("res://app/main.tscn")
const WARM_UP := 120
const SETTLE := 20
const Scout := UnitType.Value.SCOUT
const Harpoonist := UnitType.Value.HARPOONIST
const Guardian := UnitType.Value.GUARDIAN

var _out := ""
var _app: App
var _folder := TempFolder.new()
var _game: Game
var _human: Player
var _near: Vector2i
var _far: Vector2i


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("usage: fight_capture.gd -- <out dir>")
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
	_human.units_per_level[1] = DomainSamples.units({Scout: 6, Harpoonist: 4, Guardian: 2})
	_near = Vector2i(_human.base_x + 2, _human.base_y)
	_far = Vector2i(_human.base_x + 2, _human.base_y + 2)
	_lair(_near, MonsterLair.new(MonsterDifficulty.Value.EASY, 3, MonsterFamily.Value.HUNTER))
	_lair(_far, MonsterLair.new(MonsterDifficulty.Value.HARD, 300))
	_app.flow.play(_game)
	(_app.flow.current as GameHud).show_tab(GameTab.Value.MAP)
	await _tap(_near)
	await _shot("fight_lair_sheet")
	await _prepare()
	var page := _selection()
	page.rows[Harpoonist].set_value(3)
	page.rows[Scout].set_value(2)
	await _shot("fight_selection")
	TranslationServer.set_locale("en")
	await _shot("fight_selection_en")
	TranslationServer.set_locale("fr")
	_human.units_per_level[1] = DomainSamples.units({Scout: 6, Harpoonist: 1, Guardian: 2})
	page.actions_bar.launch_button.pressed.emit()
	await _shot("fight_refused")
	_human.units_per_level[1] = DomainSamples.units({Scout: 6, Harpoonist: 4, Guardian: 2})
	page.launch()
	await _report("fight_report_won")
	_app.modals.close_top()
	await _shot("fight_map_beaten")
	await _fight_lost()
	_folder.remove()
	quit(0)


## The hard lair, attacked with one scout.
func _fight_lost() -> void:
	await _tap(_far)
	await _shot("fight_lair_generic")
	await _prepare()
	var page := _selection()
	page.rows[Scout].set_value(1)
	page.launch()
	await _report("fight_report_lost")


## The report on top: its top, then its end.
func _report(shot_name: String) -> void:
	await _shot(shot_name)
	if shot_name == "fight_report_won":
		var report := _app.modals.top() as FightSummaryPage
		var scroll := report.find_children("*", "ScrollContainer", true, false)[0] as ScrollContainer
		scroll.scroll_vertical = 100000
		await _shot(shot_name + "_end")


func _tap(at: Vector2i) -> void:
	_app.world.map.cell_tapped.emit(1, at.x, at.y)
	await _frames(1)


func _prepare() -> void:
	(_app.modals.top() as MonsterLairSheet).prepare_button.pressed.emit()
	await _frames(1)


func _selection() -> ArmySelection:
	return _app.modals.top() as ArmySelection


func _lair(at: Vector2i, lair: MonsterLair) -> void:
	_game.levels[1].set_cell(at.x, at.y, MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.MONSTER_LAIR, lair))


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
