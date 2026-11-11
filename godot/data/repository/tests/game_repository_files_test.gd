extends TestCase
## Not in the Dart files: what GameRepository does with the files of its
## folder it did not write whole. An unreadable save is skipped and named,
## never stopping the others; what is not a save is left alone; a save it
## cannot write keeps the previous one.

var temp := TempFolder.new()
var repository := GameRepository.new(temp.path)


func after_each() -> void:
	temp.remove()


func _write(file: String, text: String) -> void:
	AtomicFile.write(temp.path.path_join(file), text)


func test_skips_an_unreadable_save_and_names_it_with_why() -> void:
	repository.save(Game.single_player(Player.new("Nemo")))
	_write("game-2.json", "{\"format\":1,\"game\":{\"turn\"")
	_write("game-3.json", "{\"format\":9}")
	repository.save(Game.single_player(Player.new("Aronnax")))
	var found := GameRepository.new(temp.path).load_all()
	assert_eq(found.games.map(func(g: Game) -> String: return g.human_player().name), ["Nemo", "Aronnax"])
	assert_eq(found.unreadable.keys(), ["game-2.json", "game-3.json"])
	assert_true(found.unreadable["game-2.json"].begins_with("not a save: "), found.unreadable["game-2.json"])
	assert_eq(found.unreadable["game-3.json"], "saved by a newer version (format 9, this one reads up to 1)")


func test_leaves_alone_what_is_not_a_save() -> void:
	repository.save(Game.single_player(Player.new("Nemo")))
	for file: String in ["game-1.json.tmp", "game-01.json", "game-0.json", "game-x.json", "notes.txt", "game-2.txt"]:
		_write(file, "{}")
	var found := GameRepository.new(temp.path).load_all()
	assert_eq(found.games.size(), 1)
	assert_eq(found.unreadable, {} as Dictionary[String, String])
	repository.save(Game.single_player(Player.new("Aronnax")))
	assert_true(FileAccess.file_exists(temp.path.path_join("game-2.json")))


func test_orders_the_saves_by_number_not_by_name() -> void:
	for n: int in [10, 9, 2]:
		_write("game-%d.json" % n, SaveCodec.to_text(Game.single_player(Player.new("P%d" % n))))
	var games := repository.load_all().games
	assert_eq(games.map(func(g: Game) -> String: return g.human_player().name), ["P2", "P9", "P10"])


func test_a_save_it_cannot_write_keeps_the_previous_one() -> void:
	var game := Game.single_player(Player.new("Nemo"))
	repository.save(game)
	DirAccess.make_dir_recursive_absolute(temp.path.path_join("game-1.json.tmp"))
	game.turn = 7
	assert_ne(repository.save(game), OK)
	assert_eq(GameRepository.new(temp.path).load_all().games[0].turn, 1)


func test_a_game_whose_file_is_gone_cannot_be_deleted() -> void:
	var game := Game.single_player(Player.new("Nemo"))
	repository.save(game)
	DirAccess.remove_absolute(temp.path.path_join("game-1.json"))
	assert_ne(repository.delete_game(game), OK)
