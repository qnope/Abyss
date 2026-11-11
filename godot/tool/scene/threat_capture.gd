extends SceneTree
## Renders the threats for review, as a phone held upright shows them.
## tool/scene_capture.sh runs it:
##   godot --path godot --resolution 780x1688 --script res://tool/scene/threat_capture.gd -- <out dir>
## writes <out dir>/threat_bars.png (the game screen with the noise gauge, the
## raids lost in a row, the guardians' strip and the kraken wave's),
## threat_bars_raid.png (the raid alert in place of the gauge),
## threat_confirm.png (the question of a turn in which the raid, the predators,
## the guardians and the kraken wave all strike), threat_summary.png (what that
## turn told), threat_summary_announced.png (a raid and a wave announced),
## threat_raid_report.png and threat_raid_report_end.png (the raid lost, top
## and foot), threat_predators_report.png (the school of predators),
## threat_raid_report_won.png (a raid won behind a rampart),
## threat_wave_report.png (the kernel taken a level) and threat_wave_report_en.png,
## each with its draw calls and primitives. The save goes under user:// and is
## removed at the end.

const MainScene := preload("res://app/main.tscn")
const WARM_UP := 120
const SETTLE := 20

var _out := ""
var _app: App
var _folder := TempFolder.new()


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("usage: threat_capture.gd -- <out dir>")
		quit(2)
		return
	_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	_capture()


func _capture() -> void:
	_start()
	await _frames(WARM_UP)
	var war := LeviathanScene.of()
	LeviathanScene.play_until(war, LeviathanScene.strike_turn(war))
	var player := war.human()
	player.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 1
	player.raid_state.add_noise(27)
	player.raid_state.lost_in_a_row = 2
	player.volcano_state.announce(VolcanoWaveFactory.from_kernel_level(1), war.game.turn)
	_app.flow.play(war.game)
	_app.flow.controller.session.changed.emit()
	await _shot("threat_bars")
	player.raid_state.announce(ThreatSamples.wave(), war.game.turn)
	_app.flow.controller.session.changed.emit()
	await _shot("threat_bars_raid")
	player.event_state.predator_wave = ThreatSamples.wave()
	player.event_state.predators_turn = war.game.turn
	_app.flow.controller.end_turn.request()
	await _shot("threat_confirm")
	player.raid_state.lost_in_a_row = 0
	(_app.modals.top() as TurnConfirmation).confirm_button.pressed.emit()
	await _shot("threat_summary")
	_app.modals.close_top()
	await _shot("threat_raid_report")
	_scroll_to_end()
	await _shot("threat_raid_report_end")
	_app.modals.close_top()
	await _shot("threat_predators_report")
	_app.modals.close_top()
	await _shot("threat_wave_report")
	_app.modals.close_top()
	_open(TurnSummary.new(ThreatSamples.result(null, ThreatSamples.wave(), null, ThreatSamples.wave())))
	await _shot("threat_summary_announced")
	_app.modals.close_top()
	_open(RaidReportPage.new(ThreatSamples.raid_report(true, 3)))
	await _shot("threat_raid_report_won")
	_app.modals.close_top()
	_open(VolcanoReportPage.new(ThreatSamples.volcano_report(false)))
	TranslationServer.set_locale("en")
	await _shot("threat_wave_report_en")
	_folder.remove()
	quit(0)


func _open(modal: ModalPanel) -> void:
	while _app.modals.depth() > 0:
		_app.modals.close_top()
	_app.modals.open(modal)


## The page on top scrolled to its foot.
func _scroll_to_end() -> void:
	var scroll := _app.modals.top().find_children("*", "ScrollContainer", true, false)[0] as ScrollContainer
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)


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
