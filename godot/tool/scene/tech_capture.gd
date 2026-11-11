extends SceneTree
## Renders the research tab for review, as a phone held upright shows it.
## tool/scene_capture.sh runs it:
##   godot --path godot --resolution 780x1688 --script res://tool/scene/tech_capture.gd -- <out dir>
## writes <out dir>/tech_new.png (a new game: no laboratory, the notice),
## tech_tree.png (the tree in the middle of a game: a researched branch with
## its option taken, a branch to the laboratory's limit, one just opened), tech_tree_en.png
## (the same in English), and the sheets of a touch: tech_node.png (a node to
## research: its effect and cost), tech_choice.png (a node of choice: two
## options face to face), tech_done.png (a choice already made), tech_blocked.png
## (a node of choice held back by the laboratory) and tech_branch.png (a branch
## to unlock, with the surcharge of the branches already open), each with its
## draw calls and primitives. The save goes under user:// and is removed at the end.

const MainScene := preload("res://app/main.tscn")
const WARM_UP := 120
const SETTLE := 20
const Branch := TechBranch.Value

var _out := ""
var _app: App
var _hud: GameHud
var _folder := TempFolder.new()


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("usage: tech_capture.gd -- <out dir>")
		quit(2)
		return
	_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	_capture()


func _capture() -> void:
	_start()
	await _frames(WARM_UP)
	_play(GameFactory.new_single_player("Nemo", 1))
	await _shot("tech_new")
	_play(_mid_game())
	await _shot("tech_tree")
	TranslationServer.set_locale("en")
	await _shot("tech_tree_en")
	TranslationServer.set_locale("fr")
	_open(Branch.MILITARY, 3)
	await _shot("tech_node")
	_open(Branch.EXPLORER, 2)
	await _shot("tech_choice")
	_open(Branch.MILITARY, 2)
	await _shot("tech_done")
	_open(Branch.RESOURCES, 4)
	await _shot("tech_blocked")
	_forget(Branch.EXPLORER)
	_open(Branch.EXPLORER, 0)
	await _shot("tech_branch")
	_folder.remove()
	quit(0)


## A base whose laboratory is level 3, the military branch researched to its
## second level (the second option taken), the resources branch to its third
## (the first option taken), the explorer one just opened, and stock to pay
## with.
func _mid_game() -> Game:
	var game := GameFactory.new_single_player("Nemo", 1)
	var player := game.human_player()
	player.buildings[BuildingType.Value.HEADQUARTERS].level = 4
	player.buildings[BuildingType.Value.LABORATORY].level = 3
	for resource: GameResource in player.resources.values():
		resource.amount = resource.max_storage
	var military := player.tech_branches[Branch.MILITARY]
	military.unlocked = true
	military.research_level = 2
	military.choices = [TechOption.Value.B] as Array[int]
	var resources := player.tech_branches[Branch.RESOURCES]
	resources.unlocked = true
	resources.research_level = 3
	resources.choices = [TechOption.Value.A] as Array[int]
	var explorer := player.tech_branches[Branch.EXPLORER]
	explorer.unlocked = true
	explorer.research_level = 1
	return game


## [param branch] locked again, for the sheet that unlocks it.
func _forget(branch: TechBranch.Value) -> void:
	var state := _hud.game.human_player().tech_branches[branch]
	state.unlocked = false
	state.research_level = 0
	_hud.refresh()


func _play(game: Game) -> void:
	_app.flow.play(game)
	_hud = _app.flow.current as GameHud
	_hud.show_tab(GameTab.Value.TECH)


## Closes the sheet on show and opens the one of [param level] of [param
## branch] (the branch itself at 0).
func _open(branch: TechBranch.Value, level: int) -> void:
	while _app.modals.depth() > 0:
		_app.modals.close_top()
	_hud.tech_tab.tree.target_tapped.emit(TechTarget.new(branch, level))


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
