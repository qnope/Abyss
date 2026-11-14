extends GameSessionCase
## The ways out of the game being played: a save that waits for the next
## frame is written at once when the player saves, when the app goes away
## and when the game is left, and a game left is never written again.


func test_saves_on_demand_at_once_and_leaves_nothing_waiting() -> void:
	_session.actions.set_tips_enabled(true)
	assert_eq(_session.save(), OK)
	assert_eq(_saved().size(), 1)
	assert_false(_session.is_save_waiting())
	_frames.pass_one()
	assert_eq(_saves.size(), 1, "the next frame has nothing left to write")


func test_flushing_writes_the_save_that_waits_at_once() -> void:
	_session.flush()
	assert_eq(_saves.size(), 0, "none was waiting")
	_session.actions.set_tips_enabled(true)
	_session.flush()
	assert_eq(_saved().size(), 1)
	_frames.pass_one()
	assert_eq(_saves.size(), 1)


func test_closing_writes_the_save_that_waits_then_saves_nothing_more() -> void:
	_session.actions.set_tips_enabled(true)
	_session.close()
	assert_eq(_saved().size(), 1)
	_session.actions.set_guide_enabled(true)
	_frames.pass_one()
	assert_eq(_saves.size(), 1)
	assert_eq(_on_disk_when_changed, [0], "nor does it tell a screen that is gone")


func test_a_game_deleted_once_closed_is_never_written_back() -> void:
	_session.actions.set_tips_enabled(true)
	_session.close()
	assert_eq(_repository.delete_game(_game), OK)
	_frames.pass_one()
	_session.actions.set_guide_enabled(true)
	_session.flush()
	_frames.pass_one()
	assert_eq(DirAccess.get_files_at(_repository.folder), PackedStringArray())


func test_a_listener_that_closes_it_has_the_change_saved() -> void:
	_session.changed.connect(_session.close, CONNECT_ONE_SHOT)
	_session.actions.set_tips_enabled(true)
	assert_eq(_saved().size(), 1)
	_frames.pass_one()
	assert_eq(_saves.size(), 1)
