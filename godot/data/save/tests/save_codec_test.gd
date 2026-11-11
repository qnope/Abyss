extends TestCase
## SaveCodec: a game to the text of its save and back, its format version,
## and the refusal of what it cannot read, whole or cut short, never half
## read.

var game := _game()
var text := SaveCodec.to_text(game)


static func _game() -> Game:
	var factions: Array[FactionPersonality.Value] = [FactionPersonality.Value.ANGLER_CULT]
	var found := GameFactory.new_game("Nemo", 11, Difficulty.Value.EASY, false, 0, factions, "h")
	found.created_at = DateSamples.at(2026, 3, 15)
	return found


func test_writes_the_format_then_the_game() -> void:
	assert_true(text.begins_with("{\"format\":1,\"game\":{\"humanPlayerId\":\"h\",\"players\":{\"h\":{\"name\":\"Nemo\""))
	assert_eq(SaveCodec.FORMAT, 1)


func test_reads_back_the_game_written() -> void:
	var read := SaveCodec.from_text(text)
	assert_true(read.is_read())
	assert_eq(read.problem, "")
	assert_eq(GameSnapshot.texts(read.game), GameSnapshot.texts(game))
	assert_eq(read.game.created_at, game.created_at)
	assert_eq(SaveCodec.to_text(read.game), text)


func test_reads_whole_numbers_back_as_ints() -> void:
	var read := SaveCodec.from_text(text).game
	assert_eq(typeof(read.turn), TYPE_INT)
	assert_eq(typeof(read.created_at), TYPE_INT)
	assert_eq(typeof(read.levels[1].map_seed), TYPE_INT)
	assert_eq(typeof(read.human_player().resources[ResourceType.Value.ALGAE].amount), TYPE_INT)
	assert_true(SaveCodec.to_text(read).find(".0") < 0)


func test_refuses_what_is_no_json_or_is_cut_short() -> void:
	for cut: int in [0, 1, 10, text.length() / 2, text.length() - 1]:
		var read := SaveCodec.from_text(text.left(cut))
		assert_false(read.is_read(), str(cut))
		assert_true(read.problem.begins_with("not a save: "), read.problem)
	assert_null(SaveCodec.from_text("garbage").game)


func test_refuses_a_save_of_another_shape() -> void:
	assert_eq(SaveCodec.from_text("[1]").problem, "not a save: the save is not an object")
	assert_eq(SaveCodec.from_text("{\"game\":{}}").problem, "not a save: format is missing")
	assert_eq(SaveCodec.from_text("{\"format\":\"1\"}").problem, "not a save: format is not a whole number")
	assert_eq(SaveCodec.from_text("{\"format\":1}").problem, "unreadable save: game is missing")


func test_refuses_a_newer_or_unknown_format() -> void:
	assert_eq(SaveCodec.from_text(text.replace("{\"format\":1,", "{\"format\":2,")).problem,
		"saved by a newer version (format 2, this one reads up to 1)")
	assert_eq(SaveCodec.from_text(text.replace("{\"format\":1,", "{\"format\":0,")).problem, "unknown format 0")
	assert_eq(SaveCodec.from_text(text.replace("{\"format\":1,", "{\"format\":-3,")).problem, "unknown format -3")


func test_refuses_a_field_of_the_wrong_type_with_its_name() -> void:
	var read := SaveCodec.from_text(text.replace("\"turn\":1,", "\"turn\":\"one\","))
	assert_null(read.game)
	assert_eq(read.problem, "unreadable save: turn is not a whole number")
	assert_eq(SaveCodec.from_text(text.replace("\"status\":\"playing\"", "\"status\":\"paused\"")).problem,
		"unreadable save: status: \"paused\" is no %s" % "|".join(DartEnum.names(GameStatus.Value)))
	assert_eq(SaveCodec.from_text(text.replace("\"turn\":1,", "\"turn\":1.5,")).problem,
		"unreadable save: turn is not a whole number")


func test_refuses_a_game_whose_human_is_not_among_its_players() -> void:
	var read := SaveCodec.from_text(text.replace("{\"humanPlayerId\":\"h\"", "{\"humanPlayerId\":\"ghost\""))
	assert_eq(read.problem, "unreadable save: the human player ghost is not among the players")
