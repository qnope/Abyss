extends TestCase
## Not in the Dart files: WreckEffect.settle and WreckEffect.searched, which
## test/domain/event/event_resolver_wreck_test.dart reaches through the
## resolver and an action (both left for a later lot). What each case
## answers was printed by the Dart rules themselves.

const WRECK := CellContentType.Value.WRECK
const EMPTY := CellContentType.Value.EMPTY

var _wreck := WreckEffect.new()
var _player: Player
var _game: Game
var _at: GridPosition


func before_each() -> void:
	_player = EventSamples.wreck_player()
	_game = EventSamples.wreck_game(_player)
	_wreck.on_draw(_game, _player, 12, DartRandom.new(2))
	_at = _player.event_state.wreck_position


func _content() -> CellContentType.Value:
	return _game.levels[1].cell_at(_at.x, _at.y).content


func _assert_forgotten() -> void:
	assert_null(_player.event_state.wreck_position)
	assert_null(_player.event_state.wreck_until_turn)


func test_nothing_to_settle_without_a_wreck() -> void:
	var player := EventSamples.wreck_player()
	assert_null(WreckEffect.settle(EventSamples.wreck_game(player), player, 12))


func test_a_wreck_left_alone_lies_until_its_last_turn_then_sinks() -> void:
	assert_eq(_at.key(), Vector2i(2, 5))
	for turn: int in range(13, 17):
		assert_null(WreckEffect.settle(_game, _player, turn))
		assert_eq(_content(), WRECK)
	var ending := WreckEffect.settle(_game, _player, 17)
	assert_eq([ending.searched, ending.until_turn], [false, 17])
	assert_eq(_content(), EMPTY)
	_assert_forgotten()


func test_a_wreck_found_late_sinks_too() -> void:
	var ending := WreckEffect.settle(_game, _player, 20)
	assert_eq([ending.searched, ending.until_turn], [false, 17])
	assert_eq(_content(), EMPTY)


func test_a_wreck_searched_is_told_once_at_the_end_of_its_turn() -> void:
	WreckEffect.searched(_player, GridPosition.new(_at.x + 1, _at.y))
	assert_true(_player.event_state.wreck_position.equals(_at))
	WreckEffect.searched(_player, GridPosition.new(_at.x, _at.y))
	assert_null(_player.event_state.wreck_position)
	assert_true(_player.event_state.wreck_searched())
	var ending := WreckEffect.settle(_game, _player, 14)
	assert_eq([ending.searched, ending.until_turn], [true, 17])
	assert_eq(_content(), WRECK)
	_assert_forgotten()
	assert_null(WreckEffect.settle(_game, _player, 15))


func test_a_cell_emptied_or_changed_since_keeps_what_it_holds() -> void:
	var map := _game.levels[1]
	map.set_cell(_at.x, _at.y, map.cell_at(_at.x, _at.y).copy_with({"collected_by": "p1"}))
	assert_false(WreckEffect.settle(_game, _player, 17).searched)
	assert_eq(_content(), WRECK)
	_assert_forgotten()
	before_each()
	map = _game.levels[1]
	map.set_cell(_at.x, _at.y, map.cell_at(_at.x, _at.y).copy_with({"content": CellContentType.Value.RUINS}))
	assert_eq(WreckEffect.settle(_game, _player, 17).until_turn, 17)
	assert_eq(_content(), CellContentType.Value.RUINS)


func test_a_wreck_whose_level_is_gone_is_forgotten() -> void:
	var map := _game.levels[1]
	_game.levels = {}
	assert_false(WreckEffect.settle(_game, _player, 17).searched)
	assert_eq(map.cell_at(_at.x, _at.y).content, WRECK)
	_assert_forgotten()


func test_no_wreck_sinks_without_a_level_or_a_site() -> void:
	var player := EventSamples.wreck_player()
	var game := EventSamples.wreck_game(player)
	game.levels = {}
	var random := DartRandom.new(2)
	assert_false(_wreck.allowed_at(game, player, 12))
	_wreck.on_draw(game, player, 12, random)
	var full := EventSamples.wreck_player(EventSamples.square_around(4, 4, 4))
	_wreck.on_draw(EventSamples.wreck_game(full), full, 12, random)
	assert_null(player.event_state.wreck_position)
	assert_null(full.event_state.wreck_position)
	assert_eq(random.next_int(1000), DartRandom.new(2).next_int(1000))
	assert_eq(WreckSites.LEVEL, 1)
