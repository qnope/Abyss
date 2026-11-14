extends TestCase
## Where a bench of the game saves it: a folder of its own beside the player's
## saves, emptied before the bench and removed after it.

var _folder: TempFolder
var _players: GameRepository


func before_each() -> void:
	_folder = TempFolder.new()
	add_cleanup(_folder.remove)
	_players = GameRepository.new(_folder.path.path_join("saves"))


func test_is_a_folder_beside_the_player_s_saves() -> void:
	assert_eq(BenchSaves.beside(GameRepository.FOLDER), "user://bench")
	var saves := BenchSaves.new(_players)
	assert_eq(saves.repository.folder, _folder.path.path_join("bench"))
	assert_false(DirAccess.dir_exists_absolute(saves.repository.folder), "nothing is written yet")


func test_keeps_its_game_out_of_the_player_s_saves() -> void:
	_players.save(SavedGameSamples.game("Alice"))
	var saves := BenchSaves.new(_players)
	saves.repository.save(SavedGameSamples.game("Bench"))
	assert_eq(DirAccess.get_files_at(saves.repository.folder), PackedStringArray(["game-1.json"]))
	var kept := _players.load_all().games
	assert_eq(kept.size(), 1)
	assert_eq(kept[0].human_player().name, "Alice")


func test_removes_its_folder_and_leaves_the_player_s_saves() -> void:
	_players.save(SavedGameSamples.game("Alice"))
	var saves := BenchSaves.new(_players)
	saves.repository.save(SavedGameSamples.game("Bench"))
	saves.remove()
	assert_false(DirAccess.dir_exists_absolute(saves.repository.folder))
	assert_eq(DirAccess.get_files_at(_players.folder), PackedStringArray(["game-1.json"]))
	saves.remove()
	assert_false(DirAccess.dir_exists_absolute(saves.repository.folder), "nothing to remove twice")


func test_starts_from_an_empty_folder_after_a_bench_cut_short() -> void:
	var cut := BenchSaves.new(_players)
	cut.repository.save(SavedGameSamples.game("Bench"))
	var saves := BenchSaves.new(_players)
	assert_false(DirAccess.dir_exists_absolute(saves.repository.folder))
