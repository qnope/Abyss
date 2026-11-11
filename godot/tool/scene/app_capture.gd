extends SceneTree
## Renders the app's screens over the 3D world for review, as a phone held
## upright shows them, on saves of its own. tool/scene_capture.sh runs it:
##   godot --path godot --resolution 780x1688 --script res://tool/scene/app_capture.gd -- <out dir>
## writes <out dir>/app_menu.png, app_menu_empty.png (no save yet),
## app_new_game.png, app_saves.png, app_story.png and app_game.png, each with
## its draw calls and primitives. The saves are written under user:// and
## removed at the end; the player's own are never read.

const MainScene := preload("res://app/main.tscn")
## Frames to let the world run before the first shot, and between shots.
const WARM_UP := 120
const SETTLE := 20

var _out := ""
var _app: App
var _folder := TempFolder.new()
## When each game is saved, hours ago, in the order the capture saves them.
var _saved_hours_ago: Array[int] = [40, 30, 1]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("usage: app_capture.gd -- <out dir>")
		quit(2)
		return
	_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	_capture()


func _capture() -> void:
	_start()
	await _frames(WARM_UP)
	await _shot("app_menu_empty")
	var alice := SavedGameSamples.game("Alice", 14)
	for game: Game in [SavedGameSamples.game("Cousteau", 31, GameStatus.Value.VICTORY),
			SavedGameSamples.game("Marin", 3), alice]:
		_app.repository.save(game)
	_app.flow.show_menu()
	await _shot("app_menu")
	_app.flow.show_new_game()
	(_app.flow.current as NewGameScreen).name_field.text = "Nemo"
	await _shot("app_new_game")
	_app.flow.show_load_game()
	await _shot("app_saves")
	_app.flow.show_story(alice)
	await _shot("app_story")
	_app.flow.play(_app.repository.load_all().games[2])
	await _shot("app_game")
	_folder.remove()
	quit(0)


func _start() -> void:
	TranslationServer.set_locale("fr")
	_app = MainScene.instantiate() as App
	_app.repository = GameRepository.new(_folder.path.path_join("saves"), _stamp)
	_app.language = LanguageSettings.new(_folder.path.path_join("settings.json"))
	_app.language.choose(LanguageChoice.Value.FRENCH)
	_app.bench = BenchOptions.new(0.0)
	root.add_child(_app)


## The time of the next save, the cards telling it against now.
func _stamp() -> int:
	return Game.now() - _saved_hours_ago.pop_front() * SavedGameSamples.HOUR


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
