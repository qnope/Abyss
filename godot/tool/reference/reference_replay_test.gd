extends TestCase
## The replay of a reference game (ReferenceReplay): `idle-normal`, whose
## journal holds no move, replays whole, its 48 turns, the raids that end
## it and its defeat, through the state Dart went through, every section
## of every turn, its journal included.


func _committed(name: String) -> CommittedGame:
	var games := CommittedGame.all()
	return games[games.find_custom(func(g: CommittedGame) -> bool: return g.name == name)]


func test_replays_a_game_without_moves_through_the_states_dart_went_through() -> void:
	var committed := _committed("idle-normal")
	var replay := ReferenceReplay.new(committed)
	var played := committed.played_turns()
	assert_eq(replay.turns.size(), played.size())
	for i: int in mini(replay.turns.size(), played.size()):
		assert_eq(replay.turns[i].turn, played[i].turn)
		assert_eq(ReplayComparison.differing(played[i].digests, replay.turns[i].digests), PackedStringArray(), "turn %d" % played[i].turn)
	assert_eq(ReplayComparison.differing(committed.final_digests(), replay.final_digests), PackedStringArray())
	assert_eq([DartEnum.name_of(GameStatus.Value, replay.game.status), replay.game.turn], [committed.status(), committed.turn()])


func test_plays_each_move_as_its_player_with_what_decode_gives() -> void:
	var committed := _committed("idle-normal")
	var json := committed.json.duplicate(true)
	json["journal"]["lastTurn"] = 2
	json["journal"]["turns"] = {"1": [
		{"do": "upgrade", "building": "headquarters"},
		{"do": "upgrade", "building": "headquarters", "player": CommittedGame.HUMAN_ID},
	]}
	var decoded: Array[Dictionary] = []
	var decode := func(move: Dictionary, random: DartRandom) -> Action:
		assert_not_null(random)
		decoded.append(move)
		return UpgradeBuildingAction.new(BuildingType.Value.HEADQUARTERS)
	var replay := ReferenceReplay.new(CommittedGame.new("two-moves", JSON.stringify(json)), decode)
	assert_eq(decoded.size(), 2)
	assert_eq(replay.turns.size(), 2, "the start, then the end of turn 1; turn 2 is the last")
	assert_eq(replay.game.turn, 2)
	assert_eq(replay.game.human_player().buildings[BuildingType.Value.HEADQUARTERS].level, 1)
