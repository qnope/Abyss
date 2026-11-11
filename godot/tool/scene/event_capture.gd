extends SceneTree
## Renders the events, the history and the replay export for review, as a
## phone held upright shows them. tool/scene_capture.sh runs it:
##   godot --path godot --resolution 780x1688 --script res://tool/scene/event_capture.gd -- <out dir>
## writes <out dir>/event_strip.png (the game with an event waiting: the strip
## under the resource bar), event_card.png and event_card_en.png (the card of
## the survivors), event_card_trade.png (the caravan's trade, the stock empty: the
## refused option), history_settings.png (the settings with the two new rows),
## history_all.png, history_combat.png and history_en.png (the
## sheet opened from the settings, then filtered, then in English),
## export_dialog.png, export_copied.png and export_old.png (the replay export
## of the game, after a copy, and of a game with no journal), each with its
## draw calls and primitives. The save goes under user:// and is removed at the
## end.

const MainScene := preload("res://app/main.tscn")
const WARM_UP := 120
const SETTLE := 20
const Type := RandomEventType.Value

var _out := ""
var _app: App
var _hud: GameHud
var _folder := TempFolder.new()


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("usage: event_capture.gd -- <out dir>")
		quit(2)
		return
	_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	_capture()


func _capture() -> void:
	_start()
	await _frames(WARM_UP)
	var game := _game()
	_play(game)
	await _shot("event_strip")
	(_hud.status_bars.bars()[0] as EventStatusBar).tap_button.pressed.emit()
	await _shot("event_card")
	TranslationServer.set_locale("en")
	await _shot("event_card_en")
	TranslationServer.set_locale("fr")
	_close_all()
	game.human_player().event_state.clear_pending()
	game.human_player().event_state.set_pending(Type.CARAVAN, game.turn)
	game.human_player().event_state.trade_from = ResourceType.Value.ALGAE
	game.human_player().event_state.trade_to = ResourceType.Value.CORAL
	game.human_player().resources[ResourceType.Value.ALGAE].amount = 0
	_hud.refresh()
	(_hud.status_bars.bars()[0] as EventStatusBar).tap_button.pressed.emit()
	await _shot("event_card_trade")
	_close_all()
	_hud.open_settings()
	await _shot("history_settings")
	(_app.modals.top() as SettingsDialog).links.history_row.pressed.emit()
	await _shot("history_all")
	var sheet := _app.modals.top() as HistorySheet
	sheet.chips.select(HistoryFilter.Value.COMBAT)
	sheet.show_filter(HistoryFilter.Value.COMBAT)
	await _shot("history_combat")
	TranslationServer.set_locale("en")
	sheet.chips.select(HistoryFilter.Value.ALL)
	sheet.show_filter(HistoryFilter.Value.ALL)
	await _shot("history_en")
	TranslationServer.set_locale("fr")
	_close_all()
	_hud.open_settings()
	(_app.modals.top() as SettingsDialog).links.export_row.pressed.emit()
	await _shot("export_dialog")
	(_app.modals.top() as ReplayExportDialog).copy_button.pressed.emit()
	await _shot("export_copied")
	_close_all()
	game.replay = null
	_app.modals.open(ReplayExportDialog.new(game))
	await _shot("export_old")
	_folder.remove()
	quit(0)


## A base at turn 8 whose player has a survivors event waiting and a history
## of every kind of entry.
func _game() -> Game:
	var game := GameFactory.new_single_player("Nemo", 1)
	game.turn = 8
	var player := game.human_player()
	player.buildings[BuildingType.Value.HEADQUARTERS].level = 4
	player.event_state.set_pending(Type.SURVIVORS, game.turn)
	player.event_state.survivors = 4
	player.history_entries.append_array([
		BuildingEntry.new(1, BuildingType.Value.ALGAE_FARM, 2),
		ResearchEntry.new(2, TechBranch.Value.MILITARY, false, 1),
		HistorySamples.combat_entry(true),
		HistorySamples.capture_entry("faille:0"),
		DescentEntry.new(4, 2, 5),
		EventEntry.new(6, Type.CARAVAN, false, true),
		HistorySamples.raid_entry(true, true),
		HistorySamples.volcano_entry(false),
		HistorySamples.combat_entry(false),
		HistorySamples.raid_entry(false),
	])
	return game


func _play(game: Game) -> void:
	_app.flow.play(game)
	_hud = _app.flow.current as GameHud


func _close_all() -> void:
	while _app.modals.depth() > 0:
		_app.modals.close_top()


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
