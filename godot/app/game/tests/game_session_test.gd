extends TestCase
## The game being played and the folder it is saved in: every change the
## player makes is saved at once, then the screen redraws (game_screen.dart:
## onChanged + repository.save).

var _folder: TempFolder
var _repository: GameRepository
var _game: Game
var _session: GameSession
var _on_disk_when_changed: Array[int] = []


func before_each() -> void:
	_folder = TempFolder.new()
	_repository = GameRepository.new(_folder.path.path_join("saves"))
	_game = GameFactory.new_single_player("Nemo", 1)
	_session = GameSession.new(_game, _repository)
	_session.changed.connect(func() -> void: _on_disk_when_changed.append(_saved().size()))


func after_each() -> void:
	_folder.remove()


func test_owns_the_game_and_the_actions_that_change_it() -> void:
	assert_eq(_session.game, _game)
	assert_eq(_session.actions.game, _game)
	assert_eq(_session.repository, _repository)


func test_saves_the_game_when_the_player_changes_it_then_redraws() -> void:
	assert_eq(_saved().size(), 0)
	_session.actions.set_tips_enabled(true)
	assert_eq(_on_disk_when_changed, [1], "saved before the screen redraws")
	var saved := _saved()[0]
	assert_true(ObjectiveMigration.state_of(saved, saved.human_player()).tips_enabled)


func test_saves_an_action_that_succeeded() -> void:
	for resource: GameResource in _game.human_player().resources.values():
		resource.amount = resource.max_storage
	var result := _session.actions.execute(UpgradeBuildingAction.new(BuildingType.Value.HEADQUARTERS))
	assert_true(result.is_success)
	var saved := _saved()[0]
	assert_eq(saved.human_player().buildings[BuildingType.Value.HEADQUARTERS].level,
		_game.human_player().buildings[BuildingType.Value.HEADQUARTERS].level)


func test_saves_nothing_for_an_action_that_failed() -> void:
	_game.human_player().resources[ResourceType.Value.CORAL].amount = 0
	_session.actions.execute(UpgradeBuildingAction.new(BuildingType.Value.HEADQUARTERS))
	assert_eq(_saved().size(), 0)
	assert_eq(_on_disk_when_changed, [])


func test_each_change_replaces_the_one_file_of_the_game() -> void:
	_session.actions.set_tips_enabled(true)
	_session.actions.set_guide_enabled(true)
	assert_eq(_saved().size(), 1)
	assert_eq(DirAccess.get_files_at(_repository.folder), PackedStringArray(["game-1.json"]))
	assert_eq(_on_disk_when_changed, [1, 1])


func test_saves_on_demand() -> void:
	assert_eq(_session.save(), OK)
	assert_eq(_saved().size(), 1)


func test_a_save_that_fails_is_told_and_the_player_goes_on() -> void:
	# The engine logs the folder it cannot make, once for each save.
	expect_error("Could not create directory")
	expect_error("Could not create directory")
	DirAccess.make_dir_recursive_absolute(_folder.path)
	FileAccess.open(_folder.path.path_join("blocker"), FileAccess.WRITE).close()
	var blocked := GameSession.new(_game, GameRepository.new(_folder.path.path_join("blocker/saves")))
	var changes := [0]
	blocked.changed.connect(func() -> void: changes[0] += 1)
	blocked.actions.set_tips_enabled(true)
	assert_ne(blocked.save(), OK)
	assert_eq(changes[0], 1, "the screen redraws all the same")


func _saved() -> Array[Game]:
	return _repository.load_all().games
