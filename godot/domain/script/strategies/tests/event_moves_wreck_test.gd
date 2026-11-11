extends TestCase
## test/domain/script/strategies/event_moves_wreck_test.dart: a script goes
## for the wreck of a random event. `_wreck` returns its game; the player
## and the wreck are read from it.


## Wreck sunk at the end of turn 12, searchable through turn 17, in a game
## during `turn`.
func _wreck(turn := 13, scouts := 1) -> Game:
	var player := EventSamples.wreck_player(null, scouts)
	var game := EventSamples.wreck_game(player, null, turn)
	WreckEffect.new().on_draw(game, player, 12, DartRandom.new(4))
	return game


func _player(game: Game) -> Player:
	return game.human_player()


func _at(game: Game) -> GridPosition:
	return _player(game).event_state.wreck_position


func _fetch(game: Game, bold := false) -> void:
	EventMoves.fetch_wreck(EventMoveSamples.script_turn_of(game), bold)


func test_a_scout_explores_the_wreck_searched_on_the_next_turn() -> void:
	var w := _wreck()
	var at := _at(w)
	_fetch(w)
	assert_eq(_player(w).pending_explorations.size(), 1)
	assert_true(_player(w).pending_explorations[0].target.equals(at))

	ExplorationResolver.resolve(w)
	w.turn += 1
	var coral := _player(w).resources[ResourceType.Value.CORAL].amount
	_fetch(w)

	assert_true(w.levels[1].cell_at(at.x, at.y).is_collected())
	assert_null(_player(w).event_state.wreck_position)
	assert_true(_player(w).resources[ResourceType.Value.CORAL].amount > coral)
	assert_true(_player(w).raid_state.noise >= 20)


func test_a_wreck_in_sight_is_searched_at_once() -> void:
	var w := _wreck(13, 0)
	_player(w).add_revealed_cell(1, _at(w))
	_fetch(w)
	assert_null(_player(w).event_state.wreck_position)


func test_left_alone_while_its_noise_would_draw_a_raid() -> void:
	var room := NoiseRules.THRESHOLD - EventRules.WRECK_NOISE
	var loud := _wreck()
	var at := _at(loud)
	_player(loud).raid_state.noise = room
	_player(loud).add_revealed_cell(1, at)
	_fetch(loud)
	assert_true(_at(loud).equals(at))

	var hidden := _wreck()
	_player(hidden).raid_state.noise = room
	_fetch(hidden)
	assert_true(_player(hidden).pending_explorations.is_empty())


func test_left_alone_while_a_raid_is_announced() -> void:
	var w := _wreck()
	_player(w).raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.EASY, 3, MonsterFamily.Value.SWARM), 14)
	_fetch(w)
	assert_true(_player(w).pending_explorations.is_empty())


func test_not_explored_in_a_storm_nor_on_its_last_turn() -> void:
	var storm := _wreck()
	_player(storm).event_state.activate(RandomEventType.Value.STORM, 14)
	_fetch(storm)
	assert_true(_player(storm).pending_explorations.is_empty())

	var last := _wreck(12 + EventRules.WRECK_TURNS)
	_fetch(last)
	assert_true(_player(last).pending_explorations.is_empty())


func test_a_bold_player_searches_the_wreck_whatever_the_noise_and_raids() -> void:
	var w := _wreck(13, 0)
	var at := _at(w)
	_player(w).raid_state.noise = NoiseRules.THRESHOLD - 1
	_player(w).add_revealed_cell(1, at)
	_fetch(w, true)
	assert_true(w.levels[1].cell_at(at.x, at.y).is_collected())


func test_a_bold_player_recruits_the_scout_it_lacks_and_sends_it() -> void:
	var w := _wreck(13, 0)
	for r: GameResource in _player(w).resources.values():
		r.amount = r.max_storage
	_player(w).buildings[BuildingType.Value.BARRACKS].level = 1
	_fetch(w, true)
	assert_eq(_player(w).pending_explorations.size(), 1)
	assert_true(_player(w).pending_explorations[0].target.equals(_at(w)))


## Not in the Dart file: no wreck, nothing to fetch; a wreck whose last turn
## is not told is never explored.
func test_without_a_wreck_or_its_last_turn_nothing_is_sent() -> void:
	var w := _wreck()
	_player(w).event_state.wreck_until_turn = null
	_fetch(w)
	assert_true(_player(w).pending_explorations.is_empty())
	_player(w).event_state.clear_wreck()
	_fetch(w, true)
	assert_true(_player(w).pending_explorations.is_empty())


## Not in the Dart file: a player who is not bold recruits no scout for it.
func test_a_cautious_player_recruits_no_scout_for_the_wreck() -> void:
	var w := _wreck(13, 0)
	for r: GameResource in _player(w).resources.values():
		r.amount = r.max_storage
	_player(w).buildings[BuildingType.Value.BARRACKS].level = 1
	_fetch(w)
	assert_eq(_player(w).units_on_level(1)[UnitType.Value.SCOUT].count, 0)
	assert_true(_player(w).pending_explorations.is_empty())
