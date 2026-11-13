extends SceneTree
## Renders the story of a turn for review, as a phone held upright shows it.
## tool/scene_capture.sh runs it:
##   godot --path godot --resolution 780x1688 --script res://tool/scene/story_capture.gd -- <out dir>
## plays the game of the map capture through the real screens, a scout out and a raid
## due, ends its turn and writes <out dir>/story_fog_hold.png and _fog_lift.png (the
## cells the scout saw under their clouds, then lifting, the "Passer" button over the
## map), story_siege_clash.png and _siege_breach.png (the raid besieging the base, a
## clash, then the breach) and story_summary.png (the summary that opens once "Passer"
## skipped the rest), each with its draw calls and primitives. The effects are driven by
## hand, a moment at a time. The save goes under user:// and is removed at the end.

const MainScene := preload("res://app/main.tscn")
const WARM_UP := 120
const SETTLE := 20

var _out := ""
var _app: App
var _folder := TempFolder.new()


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("usage: story_capture.gd -- <out dir>")
		quit(2)
		return
	_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	_capture()


func _capture() -> void:
	_start()
	await _frames(WARM_UP)
	var game := MapCaptureGame.of_three_levels()
	var human := game.human_player()
	game.turn = 12
	human.raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.MEDIUM, 6, MonsterFamily.Value.HUNTER), 12)
	_app.flow.play(game)
	(_app.flow.current as GameHud).show_tab(GameTab.Value.MAP)
	await _frames(SETTLE)
	var base := Vector2i(human.base_x, human.base_y)
	_app.flow.controller.end_turn.request()
	(_app.modals.top() as TurnConfirmation).confirm_button.pressed.emit()
	var camera := _app.world.map.camera
	camera.rig.look(0.0, -58.0, camera.rig.default_distance * 0.5)
	camera.rig.target = MapGrid.at(base.x - 5, base.y, 26, 26)
	var lift := _play() as FogLift
	await _shot("story_fog_hold")
	lift.advance(0.9)
	await _shot("story_fog_lift")
	lift.finish()
	camera.rig.target = MapGrid.at(base.x, base.y, 26, 26)
	var siege := _play() as SiegeEffect
	await _step(siege, siege.timeline.clashes().hit_at(0) - siege.elapsed + 0.05, "story_siege_clash")
	await _step(siege, siege.timeline.impact() + SiegeTimeline.OUTCOME * 0.5 - siege.elapsed, "story_siege_breach")
	var skip := _find_skip(_app)
	skip.button.pressed.emit()
	await _shot("story_summary")
	_folder.remove()
	quit(0)


## The effect the map is playing, time stopped: it is driven by hand.
func _play() -> MapEffect:
	var effects := _app.world.map.effects
	effects.set_process(false)
	return effects.current


func _find_skip(node: Node) -> StorySkipButton:
	if node is StorySkipButton:
		return node
	for child in node.get_children():
		var found := _find_skip(child)
		if found != null:
			return found
	return null


func _step(effect: MapEffect, seconds: float, shot_name: String) -> void:
	effect.advance(seconds)
	await _shot(shot_name)


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
