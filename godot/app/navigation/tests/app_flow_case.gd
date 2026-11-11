class_name AppFlowCase
extends UiTestCase
## What the tests of the flow between the screens share: a folder of saves and
## settings of their own, a flow showing its screens on a plain control, the
## games it saves and the cards it lists.

var _folder: TempFolder
var _repository: GameRepository
var _language: LanguageSettings
var _flow: AppFlow
var _screens: Control
var _clock := SavedGameSamples.now()
var _playing: Array[bool] = []


func before_each() -> void:
	_folder = TempFolder.new()
	add_cleanup(_folder.remove)
	_repository = GameRepository.new(_folder.path.path_join("saves"), _tick)
	_language = LanguageSettings.new(_folder.path.path_join("settings.json"))
	_screens = mount(Control.new())
	_flow = AppFlow.new(_repository, _language, _screens, modals())
	_flow.playing_changed.connect(_playing.append)


## Saves a game of [param player_name]; each save is an hour later than the
## last, so that the latest saved is the latest played.
func _save(player_name: String, turn := 1) -> Game:
	var game := SavedGameSamples.game(player_name, turn)
	_repository.save(game)
	return game


## A file where a folder is wanted: nothing can be written under "blocker".
func _block_folder() -> void:
	DirAccess.make_dir_recursive_absolute(_folder.path)
	FileAccess.open(_folder.path.path_join("blocker"), FileAccess.WRITE).close()


func _card_of(player_name: String) -> SaveCard:
	var listed := (_flow.current as LoadGameScreen).list.cards()
	var found := listed.filter(func(card: SaveCard) -> bool: return card.summary.player_name == player_name)
	return null if found.is_empty() else found[0]


func _tick() -> int:
	_clock += SavedGameSamples.HOUR
	return _clock
