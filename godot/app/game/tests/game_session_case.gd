class_name GameSessionCase
extends TestCase
## What the tests of the game being played share: a session on a folder of
## saves of its own, the frames the test makes pass, what was on the disk
## each time the screen was told to redraw, and the saves written.

var _folder: TempFolder
var _repository: GameRepository
var _game: Game
var _session: GameSession
var _frames := ManualFrames.new()
var _on_disk_when_changed: Array[int] = []
## One for each save written or tried: the repository stamps it.
var _saves: Array[int] = []


func before_each() -> void:
	_folder = TempFolder.new()
	_repository = GameRepository.new(_folder.path.path_join("saves"), _stamp)
	_game = GameFactory.new_single_player("Nemo", 1)
	_session = GameSession.new(_game, _repository, _frames.next_frame())
	_session.changed.connect(func() -> void: _on_disk_when_changed.append(_saved().size()))


func after_each() -> void:
	# The listener of `changed` holds the test: let go of the session it is on.
	_session = null
	_folder.remove()


func _saved() -> Array[Game]:
	return _repository.load_all().games


func _stamp() -> int:
	_saves.append(_saves.size())
	return Game.now()
