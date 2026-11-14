extends GameSessionCase
## The game being played and the folder it is saved in: a change the player
## makes redraws the screen at once and is saved on the next frame
## (game_screen.dart: onChanged + repository.save).


func test_owns_the_game_and_the_actions_that_change_it() -> void:
	assert_eq(_session.game, _game)
	assert_eq(_session.actions.game, _game)
	assert_eq(_session.repository, _repository)
	assert_false(_session.is_save_waiting())


func test_a_change_redraws_at_once_and_is_saved_on_the_next_frame() -> void:
	_session.actions.set_tips_enabled(true)
	assert_eq(_on_disk_when_changed, [0], "the screen redraws before anything is written")
	assert_true(_session.is_save_waiting())
	_frames.tell()
	assert_eq(_saves.size(), 0, "the frame of the action is not drawn yet")
	_frames.pass_one()
	assert_false(_session.is_save_waiting())
	var saved := _saved()[0]
	assert_true(ObjectiveMigration.state_of(saved, saved.human_player()).tips_enabled)


func test_saves_an_action_that_succeeded() -> void:
	for resource: GameResource in _game.human_player().resources.values():
		resource.amount = resource.max_storage
	var result := _session.actions.execute(UpgradeBuildingAction.new(BuildingType.Value.HEADQUARTERS))
	assert_true(result.is_success)
	_frames.pass_one()
	var saved := _saved()[0]
	assert_eq(saved.human_player().buildings[BuildingType.Value.HEADQUARTERS].level,
		_game.human_player().buildings[BuildingType.Value.HEADQUARTERS].level)


func test_saves_nothing_for_an_action_that_failed() -> void:
	_game.human_player().resources[ResourceType.Value.CORAL].amount = 0
	_session.actions.execute(UpgradeBuildingAction.new(BuildingType.Value.HEADQUARTERS))
	assert_false(_session.is_save_waiting())
	_frames.pass_one()
	assert_eq(_saves.size(), 0)
	assert_eq(_on_disk_when_changed, [])


func test_the_changes_of_a_frame_are_one_save() -> void:
	_session.actions.set_tips_enabled(true)
	_session.actions.set_guide_enabled(true)
	assert_eq(_on_disk_when_changed, [0, 0])
	_frames.pass_one()
	_frames.pass_one()
	assert_eq(_saves.size(), 1)
	var saved := ObjectiveMigration.state_of(_saved()[0], _saved()[0].human_player())
	assert_true(saved.tips_enabled and saved.tutorial_enabled, "both changes are in it")


func test_each_save_replaces_the_one_file_of_the_game() -> void:
	_session.actions.set_tips_enabled(true)
	_frames.pass_one()
	_session.actions.set_guide_enabled(true)
	_frames.pass_one()
	assert_eq(_saves.size(), 2)
	assert_eq(DirAccess.get_files_at(_repository.folder), PackedStringArray(["game-1.json"]))


func test_waits_for_the_frame_of_the_scene_tree_unless_given_another() -> void:
	var session := GameSession.new(_game, _repository)
	session.actions.set_tips_enabled(true)
	assert_true(session.is_save_waiting())
	assert_eq(_saves.size(), 0)
	session.close()
	assert_eq(_saves.size(), 1)


func test_let_go_while_its_save_waits_it_leaves_the_scene_tree() -> void:
	var frames := (Engine.get_main_loop() as SceneTree).process_frame
	var listeners := frames.get_connections().size()
	var session := GameSession.new(_game, _repository)
	session.actions.set_tips_enabled(true)
	assert_eq(frames.get_connections().size(), listeners + 1)
	var let_go: WeakRef = weakref(session)
	session = null
	assert_null(let_go.get_ref(), "the wait does not hold the session")
	assert_eq(frames.get_connections().size(), listeners, "nor the tree the wait")
	assert_eq(_saves.size(), 0)


func test_a_save_that_fails_is_told_and_the_player_goes_on() -> void:
	# The engine logs the folder it cannot make, once for each save.
	expect_error("Could not create directory")
	expect_error("Could not create directory")
	DirAccess.make_dir_recursive_absolute(_folder.path)
	FileAccess.open(_folder.path.path_join("blocker"), FileAccess.WRITE).close()
	var blocked := GameSession.new(_game, GameRepository.new(_folder.path.path_join("blocker/saves")),
		_frames.next_frame())
	var changes := [0]
	blocked.changed.connect(func() -> void: changes[0] += 1)
	blocked.actions.set_tips_enabled(true)
	_frames.pass_one()
	assert_false(blocked.is_save_waiting(), "the next change saves it again")
	assert_ne(blocked.save(), OK)
	assert_eq(changes[0], 1, "the screen redraws all the same")
