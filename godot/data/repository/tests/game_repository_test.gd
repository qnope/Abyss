extends TestCase
## GameRepository: the tests of test/data/game_repository_roundtrip_test,
## game_repository_initialize_test and game_last_played_save_test that are
## not about Hive, on a folder of their own; and the files it skips.

var temp := TempFolder.new()
## The time of the clock, its first item: the clock reads it, not this
## test, which it would keep alive.
var clock: Array[int] = [DateSamples.at(2026, 6, 1, 10)]
var repository: GameRepository


func before_each() -> void:
	var time := clock
	repository = GameRepository.new(temp.path, func() -> int: return time[0])


func after_each() -> void:
	temp.remove()


static func _game(name: String) -> Game:
	return Game.single_player(Player.with_base(name, 2, 3, 10, 10))


## As a new launch would read the folder.
func _reload() -> Array[Game]:
	return GameRepository.new(temp.path).load_all().games


func _names(games: Array[Game]) -> Array:
	return games.map(func(g: Game) -> String: return g.human_player().name)


func test_a_round_trip_keeps_the_player_and_the_game() -> void:
	var player := Player.with_base("Nemo", 7, 9, 20, 20, "human-uuid")
	player.resources[ResourceType.Value.ALGAE] = GameResource.new(ResourceType.Value.ALGAE, 777, 5000)
	var original := Game.single_player(player)
	assert_eq(repository.save(original), OK)
	var loaded := _reload()
	assert_eq(loaded.size(), 1)
	assert_eq(GameSnapshot.texts(loaded[0]), GameSnapshot.texts(original))
	assert_eq(loaded[0].human_player().revealed_cells(), player.revealed_cells())
	assert_eq(loaded[0].created_at, original.created_at)


func test_an_empty_or_missing_folder_holds_no_game() -> void:
	assert_eq(repository.load_all().games, [] as Array[Game])
	assert_false(DirAccess.dir_exists_absolute(temp.path))


func test_save_adds_new_games_and_load_all_returns_them_in_order() -> void:
	for name: String in ["Nemo", "Aronnax", "Conseil"]:
		repository.save(_game(name))
	assert_eq(_names(_reload()), ["Nemo", "Aronnax", "Conseil"])
	assert_eq(DirAccess.get_files_at(temp.path), PackedStringArray(["game-1.json", "game-2.json", "game-3.json"]))


func test_saving_a_stored_game_updates_it_in_place() -> void:
	var game := _game("Nemo")
	repository.save(game)
	game.turn = 9
	game.human_player().resources[ResourceType.Value.ALGAE].amount = 1234
	repository.save(game)
	var loaded := _reload()
	assert_eq(loaded.size(), 1)
	assert_eq(loaded[0].turn, 9)
	assert_eq(loaded[0].human_player().resources[ResourceType.Value.ALGAE].amount, 1234)


func test_a_loaded_game_saved_again_replaces_its_own_file() -> void:
	repository.save(_game("Nemo"))
	repository.save(_game("Aronnax"))
	var again := GameRepository.new(temp.path)
	var aronnax := again.load_all().games[1]
	aronnax.turn = 4
	again.save(aronnax)
	assert_eq(DirAccess.get_files_at(temp.path).size(), 2)
	assert_eq(_reload()[1].turn, 4)


func test_saving_stamps_when_the_game_was_last_played_and_the_stamp_is_kept() -> void:
	var game := _game("Nemo")
	repository.save(game)
	assert_eq(game.last_played_at(), DateSamples.at(2026, 6, 1, 10))
	clock[0] = DateSamples.at(2026, 6, 2, 18, 45)
	repository.save(game)
	assert_eq(game.last_played_at(), DateSamples.at(2026, 6, 2, 18, 45))
	assert_eq(_reload()[0].last_played_at(), DateSamples.at(2026, 6, 2, 18, 45))


func test_the_default_repository_stamps_with_the_current_time() -> void:
	var before := Game.now()
	var game := _game("Nemo")
	GameRepository.new(temp.path).save(game)
	assert_true(game.last_played_at() >= before and game.last_played_at() <= Game.now())
	assert_eq(GameRepository.new().folder, "user://saves")


func test_deleting_a_stored_game_removes_only_that_game() -> void:
	var aronnax := _game("Aronnax")
	repository.save(_game("Nemo"))
	repository.save(aronnax)
	repository.save(_game("Conseil"))
	assert_eq(repository.delete_game(aronnax), OK)
	assert_eq(_names(_reload()), ["Nemo", "Conseil"])
	assert_eq(repository.delete_game(_game("Never stored")), OK)
	assert_eq(_names(_reload()), ["Nemo", "Conseil"])


func test_a_new_save_takes_the_number_after_the_last_one() -> void:
	var first := _game("Nemo")
	repository.save(first)
	repository.save(_game("Aronnax"))
	repository.delete_game(first)
	repository.save(_game("Conseil"))
	assert_eq(DirAccess.get_files_at(temp.path), PackedStringArray(["game-2.json", "game-3.json"]))
