extends SceneTree
## Renders the posts and the Volcanic Kernel for review, as a phone held upright
## shows them. tool/scene_capture.sh runs it:
##   godot --path godot --resolution 780x1688 --script res://tool/scene/post_capture.gd -- <out dir>
## writes <out dir>/post_sheet_guarded.png (a Faille nobody holds),
## post_selection.png (the army of the assault), post_report.png and
## post_report_end.png (its report), post_sheet_held.png and post_sheet_held_en.png
## (the Faille taken: income, defenders, what is lost if it falls),
## post_descent.png, post_descent_done.png (the units sent down), post_rival.png
## (a post a faction holds), post_kernel_guarded.png, post_kernel_report.png,
## post_kernel_held.png (the garrison panel), post_garrison_picker.png and
## post_kernel_garrisoned.png, each with its draw calls and primitives, on the
## game of PostCaptureGame. The save goes under user:// and is removed at the end.

const MainScene := preload("res://app/main.tscn")
const WARM_UP := 120
const SETTLE := 20
const Admiral := UnitType.Value.ABYSS_ADMIRAL
const Harpoonist := UnitType.Value.HARPOONIST
const Guardian := UnitType.Value.GUARDIAN
const VOLCANO := PostCaptureGame.VOLCANO

var _out := ""
var _app: App
var _folder := TempFolder.new()
var _game: Game
var _human: Player
var _faille: Vector2i
var _kernel: Vector2i


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("usage: post_capture.gd -- <out dir>")
		quit(2)
		return
	_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	_capture()


func _capture() -> void:
	_start()
	await _frames(WARM_UP)
	_game = PostCaptureGame.of_posts()
	_human = _game.human_player()
	_faille = PostCaptureGame.find(_game, 1, CellContentType.Value.TRANSITION_BASE)
	_kernel = PostCaptureGame.find(_game, VOLCANO, CellContentType.Value.VOLCANIC_KERNEL)
	_app.flow.play(_game)
	(_app.flow.current as GameHud).show_tab(GameTab.Value.MAP)
	await _faille_flow()
	await _kernel_flow()
	_folder.remove()
	quit(0)


func _faille_flow() -> void:
	await _tap(1, _faille)
	await _shot("post_sheet_guarded")
	_press("Assaut")
	var page := _app.modals.top() as ArmySelection
	page.rows[Admiral].set_value(1)
	page.rows[Harpoonist].set_value(120)
	page.rows[Guardian].set_value(60)
	await _shot("post_selection")
	page.launch()
	await _shot("post_report")
	var scroll := _app.modals.top().find_children("*", "ScrollContainer", true, false)[0] as ScrollContainer
	scroll.scroll_vertical = 100000
	await _shot("post_report_end")
	_app.modals.close_top()
	await _tap(1, _faille)
	await _shot("post_sheet_held")
	TranslationServer.set_locale("en")
	await _shot("post_sheet_held_en")
	TranslationServer.set_locale("fr")
	_press("Envoyer des unités au Niveau 2")
	(_app.modals.top() as DescentDialog).rows[Harpoonist].set_value(40)
	await _shot("post_descent")
	_press("Descendre (40 unités)")
	await _shot("post_descent_done")
	_app.modals.close_top()
	_game.levels[1].cell_at(_faille.x, _faille.y).transition_base.captured_by = _game.factions()[0].id()
	await _tap(1, _faille)
	await _shot("post_rival")
	_app.modals.close_top()


func _kernel_flow() -> void:
	await _tap(VOLCANO, _kernel)
	await _shot("post_kernel_guarded")
	_press("Lancer l'assaut")
	var page := _app.modals.top() as ArmySelection
	page.rows[Admiral].set_value(1)
	page.rows[Harpoonist].set_value(150)
	page.rows[Guardian].set_value(100)
	page.launch()
	await _shot("post_kernel_report")
	_app.modals.close_top()
	await _tap(VOLCANO, _kernel)
	await _shot("post_kernel_held")
	_press("Mettre en garnison")
	(_app.modals.top() as UnitPickerDialog).rows[Harpoonist].set_value(30)
	await _shot("post_garrison_picker")
	_press("Envoyer (30)")
	_app.modals.close_top()
	_human.volcano_state.announce(MonsterLair.new(MonsterDifficulty.Value.MEDIUM, 12), _game.turn + 1)
	await _tap(VOLCANO, _kernel)
	await _shot("post_kernel_garrisoned")


func _press(text: String) -> void:
	var found: Control = null
	for node in _app.modals.top().find_children("*", "Button", true, false):
		if (node as Button).text == text and (node as Button).is_visible_in_tree():
			found = node as Control
	(found as Button).pressed.emit()


func _tap(level: int, at: Vector2i) -> void:
	_app.world.map.cell_tapped.emit(level, at.x, at.y)
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
