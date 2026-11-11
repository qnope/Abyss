extends SceneTree
## Renders the tutorial for review, as a phone held upright shows it.
## tool/scene_capture.sh runs it:
##   godot --path godot --resolution 780x1688 --script res://tool/scene/guide_capture.gd -- <out dir>
## writes <out dir>/guide_first.png (a new game with the tutorial on: the
## guide's bubble over the turn bar and the ring on the headquarters' pad, the
## objective banner under the bars), guide_tab.png (the advice to explore: the
## halo on the Carte tab), guide_tech.png (a halo on the medallion of a
## branch), guide_cell.png (the ring on a cell of the map), guide_tip.png (two
## tips stacked), guide_objectives.png (the sheet of the objectives),
## guide_summary.png (a turn that completed objectives, explored and missed a
## temporary one) and guide_summary_en.png (the same in English), each with its
## draw calls and primitives. The save goes under user:// and is removed at the end.

const MainScene := preload("res://app/main.tscn")
const WARM_UP := 120
const SETTLE := 20

var _out := ""
var _app: App
var _hud: GameHud
var _folder := TempFolder.new()


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("usage: guide_capture.gd -- <out dir>")
		quit(2)
		return
	_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	_capture()


func _capture() -> void:
	_start()
	await _frames(WARM_UP)
	_play(_new_game())
	await _shot("guide_first")
	_play(GuideSamples.guide_game(ObjectiveId.Value.EXPLORE))
	await _shot("guide_tab")
	_hud.show_tab(GameTab.Value.TECH)
	_point(ObjectiveId.Value.LABORATORY_AND_RESEARCH, GuideTarget.for_unlock({TechBranch.Value.MILITARY: true}))
	await _shot("guide_tech")
	_hud.show_tab(GameTab.Value.MAP)
	var seen := _hud.game.human_player().revealed_cells_on_level(1)
	_point(ObjectiveId.Value.EXPLORE, GuideTarget.for_cell(1, seen[0]))
	await _shot("guide_cell")
	_hud.show_tab(GameTab.Value.BASE)
	_app.modals.open(TipStack.new([TipCatalog.by_id(TipId.Value.NOISE_GAUGE), TipCatalog.by_id(TipId.Value.EVENTS)]))
	await _shot("guide_tip")
	_close_modals()
	_play(GuideSamples.guide_game(ObjectiveId.Value.TAKE_FAILLE))
	_app.modals.open(ObjectivesSheet.new(_hud.game))
	await _shot("guide_objectives")
	_close_modals()
	_app.modals.open(TurnSummary.new(_turn()))
	await _shot("guide_summary")
	TranslationServer.set_locale("en")
	await _shot("guide_summary_en")
	_folder.remove()
	quit(0)


func _new_game() -> Game:
	var game := GameFactory.new_single_player("Nemo", 1)
	game.human_player().saved_objective_state = ObjectiveState.new([], true)
	return game


## A turn that completed two objectives, explored twice and missed a wreck.
func _turn() -> TurnResult:
	var none: Array[BuildingType.Value] = []
	var found: Array[CellContentType.Value] = [CellContentType.Value.RUINS]
	var explored: Array[ExplorationResult] = [
		ExplorationResult.new(GridPosition.new(4, 2), 6, found), ExplorationResult.new(GridPosition.new(7, 5), 3)]
	var turn := TurnResult.new([], 5, 6, false, none, {}, explored)
	for id: ObjectiveId.Value in [ObjectiveId.Value.HQ_LEVEL_1, ObjectiveId.Value.ALGAE_FARM]:
		turn.objectives.append(ObjectiveCompletion.new(ObjectiveCatalog.by_id(id), {ResourceType.Value.CORAL: 30}))
	var wreck := TemporaryObjective.new(TemporaryObjectiveKind.Value.WRECK, 17)
	turn.temporary_objectives.append(TemporaryObjectiveEnd.new(wreck, TemporaryObjectiveOutcome.Value.EXPIRED))
	return turn


## Makes the guide say the lesson of [param id] and point at [param target]
## now, as the next advice would.
func _point(id: ObjectiveId.Value, target: GuideTarget) -> void:
	var scope := _hud.actions.guide
	scope.advice = GuideAdvice.new(GuideLesson.new(id), target)
	scope.changed.emit()


func _play(game: Game) -> void:
	_app.flow.play(game)
	_hud = _app.flow.current as GameHud


func _close_modals() -> void:
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
